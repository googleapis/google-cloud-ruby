#include "ruby/ruby.h"
#include "tracer.h"

static VALUE
rb_disable_tracepoints(VALUE self)
{
    VALUE file_tracepoint = rb_iv_get(self, "@file_tracepoint");
    VALUE line_tracepoint = rb_iv_get(self, "@line_tracepoint");

    if (RTEST(file_tracepoint) && RTEST(rb_tracepoint_enabled_p(file_tracepoint)))
        rb_tracepoint_disable(file_tracepoint);
    if (RTEST(line_tracepoint) && RTEST(rb_tracepoint_enabled_p(line_tracepoint)))
        rb_tracepoint_disable(line_tracepoint);

    return Qnil;
}

static int
hash_get_keys_callback(VALUE key, VALUE val, VALUE key_ary)
{
    rb_ary_push(key_ary, key);

    return ST_CONTINUE;
}

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

static VALUE
match_breakpoints(VALUE self, VALUE tracepoint_path, VALUE tracepoint_lineno)
{
    int i, j;
    char *c_tracepoint_path = rb_string_value_cstr(&tracepoint_path);
    int c_tracepoint_lineno = c_tracepoint_lineno = NUM2INT(tracepoint_lineno);

    VALUE path_breakpoints_hash = rb_iv_get(self, "@breakpoints_cache");
    VALUE breakpoints_paths = hash_get_keys(path_breakpoints_hash);
    VALUE *c_breakpoints_paths = RARRAY_PTR(breakpoints_paths);
    int breakpoints_paths_len = RARRAY_LEN(breakpoints_paths);
    VALUE matching_breakpoints = Qnil;

    for (i = 0; i < breakpoints_paths_len; i++) {
        VALUE breakpoint_path = c_breakpoints_paths[i];
        char *c_breakpoint_path = rb_string_value_cstr(&breakpoint_path);

        // Found matching file path, keep going
        if (strcmp(c_tracepoint_path, c_breakpoint_path) == 0) {
            VALUE line_breakpoint_hash = rb_hash_aref(path_breakpoints_hash, breakpoint_path);
            VALUE breakpoints_lines = hash_get_keys(line_breakpoint_hash);
            VALUE *c_breakpoints_lines = RARRAY_PTR(breakpoints_lines);
            int breakpoints_lines_len = RARRAY_LEN(breakpoints_lines);

            for (j = 0; j < breakpoints_lines_len; j++) {
                VALUE breakpoint_lineno = c_breakpoints_lines[j];
                int c_breakpoint_lineno = NUM2INT(breakpoint_lineno);

                if (c_tracepoint_lineno == c_breakpoint_lineno) {
                    matching_breakpoints = rb_hash_aref(line_breakpoint_hash, breakpoint_lineno);
                }
            }
        }
    }

    return matching_breakpoints;
}

// Return 0 if return tracepoint is already enabled. Otherwise enable return
// tracepoint and return 1.
static int
enable_return_tracepoint(VALUE self)
{
    VALUE return_tracepoint = rb_iv_get(self, "@return_tracepoint");
//    VALUE return_tracepoint_counter = rb_iv_get(self, "@return_tracepoint_counter");

    if (!RTEST(rb_tracepoint_enabled_p(return_tracepoint))) {
        rb_tracepoint_enable(return_tracepoint);
        rb_iv_set(self, "@return_tracepoint_counter", INT2NUM(0));
        return 1;
    }
    return 0;
}

static void
increment_return_tracepoint_counter(VALUE self)
{
    VALUE return_tracepoint_counter = rb_iv_get(self, "@return_tracepoint_counter");
    if (RTEST(return_tracepoint_counter)) {
        int c_return_tracepoint_counter = NUM2INT(return_tracepoint_counter) + 1;
        rb_iv_set(self, "@return_tracepoint_counter", INT2NUM(c_return_tracepoint_counter));
    }
}

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

static void
file_tracepoint_callback(VALUE tracepoint, void *data)
{
    VALUE self = (VALUE) data;
    VALUE line_tracepoint = rb_iv_get(self, "@line_tracepoint");
    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_path = rb_tracearg_path(tracepoint_arg);
    VALUE match_found = match_breakpoints_files(self, tracepoint_path);

    // Return if line_tracepoint is nil
    if (!RTEST(line_tracepoint)) {
        return;
    }

    if (RTEST(match_found)) {
        if (!RTEST(rb_tracepoint_enabled_p(line_tracepoint))) {
            rb_tracepoint_enable(line_tracepoint);
        }
        // Enable or increment return tracepoint
        if (!enable_return_tracepoint(self)) {
            increment_return_tracepoint_counter(self);
        }
    }
    else {
        if (RTEST(rb_tracepoint_enabled_p(line_tracepoint))) {
            rb_tracepoint_disable(line_tracepoint);
        }
        increment_return_tracepoint_counter(self);
    }

    return;
}

static void
return_tracepoint_callback(VALUE tracepoint, void *data)
{
    VALUE match_found;
    VALUE self = (VALUE) data;
    VALUE line_tracepoint = rb_iv_get(self, "@line_tracepoint");
    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_binding = rb_tracearg_binding(tracepoint_arg);

    VALUE caller_path_eval_str = rb_str_new_cstr("caller_locations(0, 1).first.absolute_path");
    VALUE caller_path = rb_funcall(tracepoint_binding, rb_intern("eval"), 1, caller_path_eval_str);

    if(!RTEST(caller_path)) {
        return;
    }

    match_found = match_breakpoints_files(self, caller_path);

    if (RTEST(match_found)) {
        if (!RTEST(rb_tracepoint_enabled_p(line_tracepoint))) {
            rb_tracepoint_enable(line_tracepoint);
        }
    }

    decrement_or_disable_return_tracepoint(self);

    return;
}

static void
line_tracepoint_callback(VALUE tracepoint, void *data)
{
    VALUE self = (VALUE) data;

    int i;
    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_path = rb_tracearg_path(tracepoint_arg);
    VALUE tracepoint_lineno = rb_tracearg_lineno(tracepoint_arg);
    VALUE tracepoint_binding;
    VALUE call_stack_bindings;

    VALUE matching_breakpoints = match_breakpoints(self, tracepoint_path, tracepoint_lineno);
    VALUE *c_matching_breakpoints;
    int matching_breakpoints_len;

    // If not found any breakpoints (matching_breakpoints isn't t_array type), directly return.
    if (!RB_TYPE_P(matching_breakpoints, T_ARRAY)) {
        return;
    }
    c_matching_breakpoints = RARRAY_PTR(matching_breakpoints);
    matching_breakpoints_len = RARRAY_LEN(matching_breakpoints);

    // Evaluate each of the matching breakpoint
    for (i = 0; i < matching_breakpoints_len; i++) {
        VALUE matching_breakpoint = c_matching_breakpoints[i];

        if (RTEST(matching_breakpoint)) {
            tracepoint_binding = rb_tracearg_binding(tracepoint_arg);
            call_stack_bindings = rb_funcall(tracepoint_binding, rb_intern("callers"), 0);
            rb_ary_pop(call_stack_bindings);

            rb_funcall(self, rb_intern("eval_breakpoint"), 2, matching_breakpoint, call_stack_bindings);
        }
    }

    return;
}

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


static VALUE
rb_register_tracepoints(VALUE self)
{
    int file_tracepoint_event = RUBY_EVENT_CALL | RUBY_EVENT_CLASS | RUBY_EVENT_B_CALL;
    int return_tracepoint_event = RUBY_EVENT_RETURN | RUBY_EVENT_END | RUBY_EVENT_B_RETURN;
    VALUE file_tracepoint;

    // Register the tracepoints if not registered already
    file_tracepoint = register_tracepoint(self, file_tracepoint_event, "@file_tracepoint", file_tracepoint_callback);
    register_tracepoint(self, return_tracepoint_event, "@return_tracepoint", return_tracepoint_callback);
    register_tracepoint(self, RUBY_EVENT_LINE, "@line_tracepoint", line_tracepoint_callback);

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
