/*
    Copyright 2017 Google Inc. All rights reserved.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

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
 *  tracepoint_path. Return 1 if found. Otherwise 0;
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
            return 1;
        }
    }

    return 0;
}

static VALUE
disable_line_trace_for_thread(VALUE thread);

/**
 *  match_breakpoints
 *  Check the Tracer#breakpoints_cache for any matching breakpoints of given
 *  file path and line number.
 *
 *  Return a Ruby array of breakpoints found. Qtrue if no match found, but this
 *  file contains at least one breakpoint. Qnil if event triggered in a file
 *  that doesn't contain any breakpoints.
 */
static VALUE
match_breakpoints(VALUE self, const char *c_trace_path, int c_trace_lineno)
{
    int i, j;
    VALUE path_breakpoints_hash = rb_iv_get(self, "@breakpoints_cache");
    VALUE breakpoints_paths = hash_get_keys(path_breakpoints_hash);
    VALUE *c_breakpoints_paths = RARRAY_PTR(breakpoints_paths);
    int breakpoints_paths_len = RARRAY_LEN(breakpoints_paths);
    VALUE path_match = Qnil;

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
            path_match = Qtrue;

            // Found matching breakpoints. Return the cached breakpoints array
            for (j = 0; j < breakpoints_lines_len; j++) {
                VALUE breakpoint_lineno = c_breakpoints_lines[j];
                int c_breakpoint_lineno = NUM2INT(breakpoint_lineno);

                if (c_trace_lineno == c_breakpoint_lineno) {
                    return rb_hash_aref(line_breakpoint_hash, breakpoint_lineno);
                }
            }
        }
    }

    return path_match;
}

/**
 *  line_trace_callback
 *  Callback function for thread line event tracing. It checks tracer#breakpoint_cache
 *  for any breakpoints trigger on current line called. Then trigger evaluation
 *  procedure if found matching breakpoints. It also skip breakpoints that are
 *  already marked completed.
 */
static void
line_trace_callback(rb_event_flag_t event, VALUE data, VALUE obj, ID mid, VALUE klass)
{
    VALUE self = data;
    VALUE trace_path;
    int c_trace_lineno;
    const char *c_trace_path;
    VALUE trace_binding;
    VALUE call_stack_bindings;
    ID callers_id;
    ID breakpoints_hit_id;
    VALUE matching_result;

    c_trace_path = rb_sourcefile();
    // Ensure C_trace_path is absolute path
    trace_path = rb_str_new_cstr(c_trace_path);
    trace_path = rb_file_expand_path(trace_path, Qnil);
    c_trace_path = rb_string_value_cstr(&trace_path);

    c_trace_lineno = rb_sourceline();
    matching_result = match_breakpoints(self, c_trace_path, c_trace_lineno);

    CONST_ID(callers_id, "callers");
    CONST_ID(breakpoints_hit_id, "breakpoints_hit");

    // If matching result isn't an array, it means we're in completely wrong file,
    // or not on the right line. Turn line tracing off if we're in wrong file.
    if (!RB_TYPE_P(matching_result, T_ARRAY)) {
        if (!RTEST(matching_result)) {
            disable_line_trace_for_thread(Qnil);
        }
        return;
    }

    trace_binding = rb_binding_new();
    call_stack_bindings = rb_funcall(trace_binding, callers_id, 0);
    rb_ary_pop(call_stack_bindings);

    rb_funcall(self, breakpoints_hit_id, 2, matching_result, call_stack_bindings);

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
    VALUE line_trace_set;
    ID locals_id;
    ID line_trace_thread_id;
    VALUE line_trace_thread_flag;

    CONST_ID(locals_id, "locals");
    CONST_ID(line_trace_thread_id, "gcloud_line_trace_set");
    line_trace_thread_flag = ID2SYM(line_trace_thread_id);

    if (!RTEST(thread)) {
        thread = rb_thread_current();
    }
    thread_variables_hash = rb_ivar_get(thread, locals_id);
    line_trace_set = rb_hash_aref(thread_variables_hash, line_trace_thread_flag);

    if (RTEST(line_trace_set)) {
        rb_thread_remove_event_hook(thread, line_trace_callback);
        rb_hash_aset(thread_variables_hash, line_trace_thread_flag, Qfalse);
    }

    return Qnil;
}

/**
 * enable_line_trace_for_thread
 * Turn on line even trace for current thread. Also set a flag
 * "gcloud_line_trace_set" to Qtrue in current thread's thread variable.
 */
static VALUE
enable_line_trace_for_thread(VALUE self)
{
    VALUE current_thread;
    VALUE thread_variables_hash;
    VALUE line_trace_set;
    ID locals_id;
    ID line_trace_thread_id;
    VALUE line_trace_thread_flag;

    CONST_ID(locals_id, "locals");
    CONST_ID(line_trace_thread_id, "gcloud_line_trace_set");
    line_trace_thread_flag = ID2SYM(line_trace_thread_id);

    current_thread = rb_thread_current();
    thread_variables_hash = rb_ivar_get(current_thread, locals_id);
    line_trace_set = rb_hash_aref(thread_variables_hash, line_trace_thread_flag);

    if (!RTEST(line_trace_set)) {
        rb_thread_add_event_hook(current_thread, line_trace_callback, RUBY_EVENT_LINE, self);
        rb_hash_aset(thread_variables_hash, line_trace_thread_flag, Qtrue);
    }

    return Qnil;
}

/**
 * return_trace_callback
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
return_trace_callback(void *data, rb_trace_arg_t *trace_arg)
{
    VALUE match_found;
    VALUE self = (VALUE) data;
    VALUE caller_locations;
    VALUE *c_caller_locations;
    VALUE caller_location;
    VALUE caller_path;

    ID caller_locations_id;
    ID absolute_path_id;

    CONST_ID(caller_locations_id, "caller_locations");
    CONST_ID(absolute_path_id, "absolute_path");

    caller_locations = rb_funcall(rb_mKernel, caller_locations_id, 2, INT2NUM(0), INT2NUM(1));

    if(!RTEST(caller_locations)) {
        return;
    }

    c_caller_locations = RARRAY_PTR(caller_locations);
    caller_location = c_caller_locations[0];
    caller_path = rb_funcall(caller_location, absolute_path_id, 0);

    if(!RTEST(caller_path)) {
        return;
    }

    match_found = match_breakpoints_files(self, caller_path);

    if (match_found) {
        enable_line_trace_for_thread(self);
    }

    return;
}

/**
 *  disable_return_trace_for_thread
 *  Turn off return events trace hook for a given thread. If no thread is given, it
 *  turns off line event trace hook in current thread. It only takes action if
 *  the thread has a thread variable "gcloud_return_trace_set" that's true.
 */
static VALUE
disable_return_trace_for_thread(VALUE thread)
{
    VALUE thread_variables_hash;
    VALUE return_trace_set;
    ID locals_id;
    ID return_trace_thread_id;
    VALUE return_trace_thread_flag;

    CONST_ID(locals_id, "locals");
    CONST_ID(return_trace_thread_id, "gcloud_return_trace_set");
    return_trace_thread_flag = ID2SYM(return_trace_thread_id);

    if (!RTEST(thread)) {
        thread = rb_thread_current();
    }
    thread_variables_hash = rb_ivar_get(thread, locals_id);
    return_trace_set = rb_hash_aref(thread_variables_hash, return_trace_thread_flag);

    if (RTEST(return_trace_set)) {
        rb_thread_remove_event_hook(thread, (rb_event_hook_func_t)return_trace_callback);
        rb_hash_aset(thread_variables_hash, return_trace_thread_flag, Qfalse);
    }

    return Qnil;
}

/**
 * enable_return_trace_for_thread
 * Turn on return events trace for current thread. Also set a flag
 * "gcloud_return_trace_set" to Qtrue in current thread's thread variable.
 */
static VALUE
enable_return_trace_for_thread(VALUE self)
{
    VALUE current_thread;
    VALUE thread_variables_hash;
    VALUE return_trace_set;

    ID locals_id;
    ID return_trace_thread_id;
    VALUE return_trace_thread_flag;

    CONST_ID(locals_id, "locals");
    CONST_ID(return_trace_thread_id, "gcloud_return_trace_set");
    return_trace_thread_flag = ID2SYM(return_trace_thread_id);

    current_thread = rb_thread_current();
    thread_variables_hash = rb_ivar_get(current_thread, locals_id);
    return_trace_set = rb_hash_aref(thread_variables_hash, return_trace_thread_flag);

    if (!RTEST(return_trace_set)) {
        int return_tracepoint_event = RUBY_EVENT_END | RUBY_EVENT_RETURN | RUBY_EVENT_C_RETURN | RUBY_EVENT_B_RETURN;
        rb_thread_add_event_hook2(current_thread, (rb_event_hook_func_t)return_trace_callback, return_tracepoint_event, self, RUBY_EVENT_HOOK_FLAG_RAW_ARG | RUBY_EVENT_HOOK_FLAG_SAFE);
        rb_hash_aset(thread_variables_hash, return_trace_thread_flag, Qtrue);
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
    VALUE match_found;

    if (!RB_TYPE_P(tracepoint_path, T_STRING))
        return;

    // Ensure tracepoint_path is absolute path
    tracepoint_path = rb_file_expand_path(tracepoint_path, Qnil);

    match_found = match_breakpoints_files(self, tracepoint_path);

    if (match_found) {
        enable_line_trace_for_thread(self);
        enable_return_trace_for_thread(self);
    }
    else {
        disable_line_trace_for_thread(Qnil);
    }

    return;
}

#ifdef RUBY_EVENT_FIBER_SWITCH
static void
fiber_tracepoint_callback(VALUE tracepoint, void *data)
{
    VALUE self = (VALUE) data;
    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_lineno = rb_tracearg_lineno(tracepoint_arg);
    int c_tracepoint_lineno = NUM2INT(tracepoint_lineno);

    // Only if lineno is greater than 0, then we know this event is triggered from
    // fiber execution, and we blindly starts line_trace.
    if (c_tracepoint_lineno > 0) {
        enable_line_trace_for_thread(self);
    }

    return;
}
#endif

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
 * rb_disable_traces
 * This is implmenetation of Tracer#disable_traces methods. It disables
 * tracer#file_tracepoint, tracer#fiber_tracepoint, return even tracing, and
 * line event tracing for all threads.
 */
static VALUE
rb_disable_traces(VALUE self)
{
    VALUE file_tracepoint;
    VALUE fiber_tracepoint;
    VALUE threads;
    VALUE *c_threads;
    int c_threads_len;
    VALUE thread;
    int i;
    ID alive_q_id;
    ID list_id;

    CONST_ID(alive_q_id, "alive?");
    CONST_ID(list_id, "list");

    file_tracepoint = rb_iv_get(self, "@file_tracepoint");
    threads = rb_funcall(rb_cThread, list_id, 0);
    c_threads_len = RARRAY_LEN(threads);
    c_threads = RARRAY_PTR(threads);
    UNUSED(fiber_tracepoint);

    if (RTEST(file_tracepoint) && RTEST(rb_tracepoint_enabled_p(file_tracepoint)))
        rb_tracepoint_disable(file_tracepoint);

#ifdef RUBY_EVENT_FIBER_SWITCH
    fiber_tracepoint= rb_iv_get(self, "@fiber_tracepoint");
    if (RTEST(fiber_tracepoint) && RTEST(rb_tracepoint_enabled_p(fiber_tracepoint)))
        rb_tracepoint_disable(fiber_tracepoint);
#endif

    for (i = 0; i < c_threads_len; i++) {
        thread = c_threads[i];
        if (RTEST(rb_funcall(thread, alive_q_id, 0))) {
            disable_line_trace_for_thread(thread);
            disable_return_trace_for_thread(thread);
        }
    }

    return Qnil;
}

/**
 * rb_enable_traces
 * This is the implementation of Tracer#enable_traces methods. It creates
 * the tracer#file_tracepoints and tracer#fiber_tracepoints for the first time
 * called. Then it also enables them immediately upon creation.
 */
static VALUE
rb_enable_traces(VALUE self)
{
    VALUE file_tracepoint;
    VALUE fiber_tracepoint;

    file_tracepoint = register_tracepoint(self, FILE_TRACEPOINT_EVENT, "@file_tracepoint", file_tracepoint_callback);
    UNUSED(fiber_tracepoint);

    // Immediately activate file tracepoint and fiber tracepoint
    if (RTEST(file_tracepoint) && !RTEST(rb_tracepoint_enabled_p(file_tracepoint))) {
        rb_tracepoint_enable(file_tracepoint);
    }
#ifdef RUBY_EVENT_FIBER_SWITCH
    fiber_tracepoint = register_tracepoint(self, RUBY_EVENT_FIBER_SWITCH, "@fiber_tracepoint", fiber_tracepoint_callback);
    if (RTEST(fiber_tracepoint) && !RTEST(rb_tracepoint_enabled_p(fiber_tracepoint))) {
        rb_tracepoint_enable(fiber_tracepoint);
    }
#endif
    return Qnil;
}

/**
 * rb_disable_traces_for_thread
 * It disables line tracing and return event tracing for current thread.
 */
static VALUE
rb_disable_traces_for_thread(VALUE self)
{
    VALUE thread = rb_thread_current();
    disable_line_trace_for_thread(thread);
    disable_return_trace_for_thread(thread);

    return Qnil;
}

void
Init_tracer(VALUE mDebugger)
{
    VALUE cTracer = rb_define_class_under(mDebugger, "Tracer", rb_cObject);

    rb_define_method(cTracer, "enable_traces", rb_enable_traces, 0);
    rb_define_method(cTracer, "disable_traces", rb_disable_traces, 0);
    rb_define_method(cTracer, "disable_traces_for_thread", rb_disable_traces_for_thread, 0);
}
