#include "ruby/ruby.h"
#include "ruby/debug.h"
#include "tracer.h"


/**
 *  hash_get_keys_callback
 *  Helper callback function for hash_get_keys.
 */
static int
hash_get_keys_callback(VALUE key, VALUE val, VALUE key_ary)
{
    rb_ary_push(key_ary, key);

    return ST_CONTINUE;
}

/**
 * hash_get_keys
 * Helper function to return an array of all the keys of a given Ruby array
 */
static VALUE
hash_get_keys(VALUE hash)
{
    VALUE key_ary;

    if(!RB_TYPE_P(hash, T_HASH)) {
        return Qnil;
    }

    key_ary = rb_ary_new();

    rb_hash_foreach(hash, hash_get_keys_callback, key_ary);

    return key_ary;
}

/**
 *  match_breakpoints_files
 *  Check the Tracer#breakpoints_cache if any breakpoints match the given
 *  tracepoint_path. Return Qtrue if found. Otherwise Qfalse;
 */
static VALUE
match_breakpoints_files(VALUE self, VALUE tracepoint_path)
{
    int i;
    char *c_tracepoint_path = rb_string_value_cstr(&tracepoint_path);

    VALUE path_breakpoints_hash = rb_iv_get(self, "@breakpoints_cache");
    VALUE breakpoints_paths = hash_get_keys(path_breakpoints_hash);
    VALUE *c_breakpoints_paths = RARRAY_PTR(breakpoints_paths);
    int breakpoints_paths_len = RARRAY_LEN(breakpoints_paths);

    for (i = 0; i < breakpoints_paths_len; i++) {
        VALUE breakpoint_path = c_breakpoints_paths[i];
        char *c_breakpoint_path = rb_string_value_cstr(&breakpoint_path);

        if (strcmp(c_tracepoint_path, c_breakpoint_path) == 0) {
            return Qtrue;
        }
    }

    return Qfalse;
}

/**
 *  match_breakpoints
 *  Check the Tracer#breakpoints_cache for any matching breakpoints of given
 *  file path and line number.
 *
 *  Return a Ruby array of breakpoints found. Qnil if no match found.
 */
static VALUE
match_breakpoints(VALUE self, const char *c_trace_path, int c_trace_lineno)
{
    int i, j;

    VALUE path_breakpoints_hash = rb_iv_get(self, "@breakpoints_cache");
    VALUE breakpoints_paths = hash_get_keys(path_breakpoints_hash);
    VALUE *c_breakpoints_paths = RARRAY_PTR(breakpoints_paths);
    int breakpoints_paths_len = RARRAY_LEN(breakpoints_paths);
    VALUE matching_breakpoints = Qnil;

    // Check the file paths of @breakpoints_cache
    for (i = 0; i < breakpoints_paths_len; i++) {
        VALUE breakpoint_path = c_breakpoints_paths[i];
        char *c_breakpoint_path = rb_string_value_cstr(&breakpoint_path);

        // Found matching file path, keep going and check for the line numbers
        if (strcmp(c_trace_path, c_breakpoint_path) == 0) {
            VALUE line_breakpoint_hash = rb_hash_aref(path_breakpoints_hash, breakpoint_path);
            VALUE breakpoints_lines = hash_get_keys(line_breakpoint_hash);
            VALUE *c_breakpoints_lines = RARRAY_PTR(breakpoints_lines);
            int breakpoints_lines_len = RARRAY_LEN(breakpoints_lines);

            // Found matching breakpoints. Return the cached breakpoints array
            for (j = 0; j < breakpoints_lines_len; j++) {
                VALUE breakpoint_lineno = c_breakpoints_lines[j];
                int c_breakpoint_lineno = NUM2INT(breakpoint_lineno);

                if (c_trace_lineno == c_breakpoint_lineno) {
                    matching_breakpoints = rb_hash_aref(line_breakpoint_hash, breakpoint_lineno);
                }
            }
        }
    }

    return matching_breakpoints;
}

/**
 *  line_trace_event_callback
 *  Callback function for thread line event tracing. It checks tracer#breakpoint_cache
 *  for any breakpoints trigger on current line called. Then trigger evaluation
 *  procedure if found matching breakpoints. It also skip breakpoints that are
 *  already marked completed.
 */
static void
line_trace_event_callback(rb_event_flag_t event, VALUE self, VALUE hook, ID mid, VALUE klass)
{
    const char *c_trace_path = rb_sourcefile();
    int c_trace_lineno = rb_sourceline();
    VALUE trace_binding;
    VALUE call_stack_bindings;

    int i;
    VALUE matching_breakpoints = match_breakpoints(self, c_trace_path, c_trace_lineno);
    VALUE *c_matching_breakpoints;
    VALUE matching_breakpoint;
    int matching_breakpoints_len;

    // If not found any breakpoints (matching_breakpoints isn't t_array type), directly return.
    if (!RB_TYPE_P(matching_breakpoints, T_ARRAY)) {
        return;
    }

    c_matching_breakpoints = RARRAY_PTR(matching_breakpoints);
    matching_breakpoints_len = RARRAY_LEN(matching_breakpoints);

    // Evaluate each of the matching breakpoint
    for (i = 0; i < matching_breakpoints_len; i++) {
        matching_breakpoint = c_matching_breakpoints[i];

        if (RTEST(matching_breakpoint) && !RTEST(rb_funcall(matching_breakpoint, rb_intern("complete?"), 0))) {
            trace_binding = rb_binding_new();
            call_stack_bindings = rb_funcall(trace_binding, rb_intern("callers"), 0);
            rb_ary_pop(call_stack_bindings);

            rb_funcall(self, rb_intern("eval_breakpoint"), 2, matching_breakpoint, call_stack_bindings);
        }
    }

    return;
}

/**
 *  disable_line_trace_for_thread
 *  Turn off line event trace hook for a given thread. If no thread is given, it
 *  turns off line event trace hook in current thread. It only takes action if
 *  the thread has a thread variable "gcloud_line_trace_set" that's true.
 */
static VALUE
disable_line_trace_for_thread(VALUE thread)
{
    VALUE thread_variables_hash;
    VALUE line_tracepoint_set;

    if (!RTEST(thread)) {
        thread = rb_thread_current();
    }
    thread_variables_hash = rb_ivar_get(thread, rb_intern("locals"));
    line_tracepoint_set = rb_hash_aref(thread_variables_hash, rb_str_new2("gcloud_line_trace_set"));

    if (RTEST(line_tracepoint_set)) {
        rb_thread_remove_event_hook(thread, line_trace_event_callback);
        rb_hash_aset(thread_variables_hash, rb_str_new2("gcloud_line_trace_set"), Qfalse);
    }

    return Qnil;
}


/**
 *  enable_return_tracepoint
 *  Enables the tracer#return_tracepoint if not enabled already. Returns 1 if
 *  successfully enabled. Otherwise return 0, including previously already enabled.
 */
static int
enable_return_tracepoint(VALUE self)
{
    VALUE return_tracepoint = rb_iv_get(self, "@return_tracepoint");

    if (!RTEST(rb_tracepoint_enabled_p(return_tracepoint))) {
        rb_tracepoint_enable(return_tracepoint);
        rb_iv_set(self, "@return_tracepoint_counter", INT2NUM(0));
        return 1;
    }
    return 0;
}

/**
 *  increment_return_tracepoint_counter
 *  Helper function to increment tracer#return_tracepoint_counter by 1
 */
static void
increment_return_tracepoint_counter(VALUE self)
{
    VALUE return_tracepoint_counter = rb_iv_get(self, "@return_tracepoint_counter");
    if (RTEST(return_tracepoint_counter)) {
        int c_return_tracepoint_counter = NUM2INT(return_tracepoint_counter) + 1;
        rb_iv_set(self, "@return_tracepoint_counter", INT2NUM(c_return_tracepoint_counter));
    }
}

/**
 *  decrement_or_disable_return_tracepoint
 *  Helper function to decrement tracer#return_tracepoint_counter by 1. If the
 *  counter is already at 0, automatically disable tracer#return_tracepoint and
 *  set counter to Qnil.
 */
static void
decrement_or_disable_return_tracepoint(VALUE self)
{
    VALUE return_tracepoint = rb_iv_get(self, "@return_tracepoint");
    VALUE return_tracepoint_counter = rb_iv_get(self, "@return_tracepoint_counter");
    if (RTEST(return_tracepoint_counter)) {
        int c_return_tracepoint_counter = NUM2INT(return_tracepoint_counter);
        // Decrement counter if counter is greater than 0. Otherwise disable return tracepoint and reset counter.
        if (c_return_tracepoint_counter > 0) {
            rb_iv_set(self, "@return_tracepoint_counter", INT2NUM(c_return_tracepoint_counter - 1));
        } else {
            if (RTEST(rb_tracepoint_enabled_p(return_tracepoint))) {
                rb_tracepoint_disable(return_tracepoint);
            }
            rb_iv_set(self, "@return_tracepoint_counter", Qnil);
        }
    }
}

/**
 * enable_line_tracepoint_for_thread
 * Turn on line even trace for current thread. Also set a flag
 * "gcloud_line_trace_set" to Qtrue in current thread's thread variable.
 */
static VALUE
enable_line_tracepoint_for_thread(VALUE self)
{
    VALUE current_thread = rb_thread_current();
    VALUE thread_variables_hash = rb_ivar_get(current_thread, rb_intern("locals"));
    VALUE line_tracepoint_set = rb_hash_aref(thread_variables_hash, rb_str_new2("gcloud_line_trace_set"));

    if (!RTEST(line_tracepoint_set)) {
        rb_thread_add_event_hook(current_thread, line_trace_event_callback, RUBY_EVENT_LINE, self);
        rb_hash_aset(thread_variables_hash, rb_str_new2("gcloud_line_trace_set"), Qtrue);
    }

    return Qnil;
}

/**
 * file_tracepoint_callback
 * Callback function for tracer#file_tracepoint. It gets called on
 * RUBY_EVENT_CLASS, RUBY_EVENT_CALL, RUBY_EVENT_C_CALL, and RUBY_EVENT_B_CALL
 * events. It check if any breakpoints matches current file the VM program counter
 * is in, and turn on line event tracing for that thread. Otherwise turn off
 * line tracing if in wrong file. The first time it turns on line even tracing,
 * it also turns on tracer#return_tracepoint to maintain line tracing
 * consistency when file execution interleaves. If return_tracepoint is already
 * on, it increments tracer#return_tracepoint_counter.
 */
static void
file_tracepoint_callback(VALUE tracepoint, void *data)
{
    VALUE self = (VALUE) data;
    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_path = rb_tracearg_path(tracepoint_arg);
    VALUE match_found = match_breakpoints_files(self, tracepoint_path);

    if (RTEST(match_found)) {
        enable_line_tracepoint_for_thread(self);
        // Enable or increment return tracepoint
        if (!enable_return_tracepoint(self)) {
            increment_return_tracepoint_counter(self);
        }
    }
    else {
        disable_line_trace_for_thread(Qnil);
        increment_return_tracepoint_counter(self);
    }

    return;
}

/**
 * return_tracepoint_callback
 * Callback function for tracer#return_tracepoint. It gets called on
 * RUBY_EVENT_END, RUBY_EVENT_RETURN, RUBY_EVENT_C_RETURN, and
 * RUBY_EVENT_B_RETURN events. It keeps line tracing consistent when Ruby
 * program counter interleaves files. Everytime called, it checks caller stack
 * frame's file path, if it matches any of the breakpoints, it turns line
 * event tracing back on. It also decrements tracer#return_tracepoint_counter
 * everytime called. When the counter is at 0, it disables itself, which should
 * be the same stack frame that the return_tracepoint is turned on.
 */
static void
return_tracepoint_callback(VALUE tracepoint, void *data)
{
    VALUE match_found;
    VALUE self = (VALUE) data;
    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_binding = rb_tracearg_binding(tracepoint_arg);

    VALUE caller_path_eval_str = rb_str_new_cstr("caller_locations(0, 1).first.absolute_path");
    VALUE caller_path = rb_funcall(tracepoint_binding, rb_intern("eval"), 1, caller_path_eval_str);

    if(!RTEST(caller_path)) {
        return;
    }

    match_found = match_breakpoints_files(self, caller_path);

    if (RTEST(match_found)) {
        enable_line_tracepoint_for_thread(self);
    }

    decrement_or_disable_return_tracepoint(self);

    return;
}


/**
 * register_tracepoint
 * Helper function to create a new tracepoint and set the instance varaible on
 * tracer if it doesn't exist already. Returns the existing tracepoint or the
 * newly created tracepoint.
 */
static VALUE
register_tracepoint(VALUE self, int event, const char *instance_variable_name, void (*call_back_func)(VALUE, void *))
{
    VALUE tracepoint = rb_iv_get(self, instance_variable_name);

    if (event && !RTEST(tracepoint)) {
        tracepoint = rb_tracepoint_new(Qnil, event, call_back_func, (void *)self);
        rb_iv_set(self, instance_variable_name, tracepoint);
    }

    return tracepoint;
}

/**
 * rb_disable_tracepoints
 * This is implmenetation of Tracer#disable_tracepoints methods. It disables
 * tracer#file_tracepoint, tracer#return_tracepoint, and line event tracing for
 * all threads.
 */
static VALUE
rb_disable_tracepoints(VALUE self)
{
    VALUE file_tracepoint = rb_iv_get(self, "@file_tracepoint");
    VALUE return_tracepoint = rb_iv_get(self, "@return_tracepoint");
    VALUE threads = rb_funcall(rb_cThread, rb_intern("list"), 0);
    VALUE *c_threads = RARRAY_PTR(threads);
    int c_threads_len = RARRAY_LEN(threads);
    VALUE thread;
    int i;

    if (RTEST(file_tracepoint) && RTEST(rb_tracepoint_enabled_p(file_tracepoint)))
        rb_tracepoint_disable(file_tracepoint);
    if (RTEST(return_tracepoint) && RTEST(rb_tracepoint_enabled_p(return_tracepoint)))
        rb_tracepoint_disable(return_tracepoint);

    for (i = 0; i < c_threads_len; i++) {
        thread = c_threads[i];
        if (RTEST(rb_funcall(thread, rb_intern("alive?"), 0))) {
            disable_line_trace_for_thread(thread);
        }
    }

    return Qnil;
}

/**
 * rb_register_tracepoints
 * This is the implementation of Tracer#register_tracepoints methods. It creates
 * the tracer#file_tracepoints and tracer#return_tracepoints. It also
 * immediately enables file_tracepoint.
 */
static VALUE
rb_register_tracepoints(VALUE self)
{
    int file_tracepoint_event = RUBY_EVENT_CLASS | RUBY_EVENT_CALL | RUBY_EVENT_C_CALL | RUBY_EVENT_B_CALL;
    int return_tracepoint_event = RUBY_EVENT_END | RUBY_EVENT_RETURN | RUBY_EVENT_C_RETURN | RUBY_EVENT_B_RETURN;
    VALUE file_tracepoint;

    // Register the tracepoints if not registered already
    file_tracepoint = register_tracepoint(self, file_tracepoint_event, "@file_tracepoint", file_tracepoint_callback);
    register_tracepoint(self, return_tracepoint_event, "@return_tracepoint", return_tracepoint_callback);

    // Immediately activate file tracepoint
    if (RTEST(file_tracepoint) && !RTEST(rb_tracepoint_enabled_p(file_tracepoint)))
        rb_tracepoint_enable(file_tracepoint);

    return Qnil;
}

void
Init_tracer(VALUE mDebugger)
{
    VALUE cTracer = rb_define_class_under(mDebugger, "Tracer", rb_cObject);

    rb_define_method(cTracer, "register_tracepoints", rb_register_tracepoints, 0);
    rb_define_method(cTracer, "disable_tracepoints", rb_disable_tracepoints, 0);
}
