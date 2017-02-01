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

static VALUE
match_breakpoints(VALUE self, VALUE tracepoint_path, VALUE tracepoint_lineno)
{
    int i;
    char *c_tracepoint_path = rb_string_value_cstr(&tracepoint_path);
    int c_tracepoint_lineno = -1;

    VALUE breakpoints = rb_iv_get(self, "@breakpoints_cache");
    VALUE* c_breakpoints = RARRAY_PTR(breakpoints);
    int breakpoints_len = RARRAY_LEN(breakpoints);

    if (FIXNUM_P(tracepoint_lineno)) {
        c_tracepoint_lineno = NUM2INT(tracepoint_lineno);
    }

    for(i = 0; i < breakpoints_len; i ++) {
        VALUE breakpoint = c_breakpoints[i];
        VALUE breakpoint_path = rb_funcall(breakpoint, rb_intern("path"), 0);
        char *c_breakpoint_path = rb_string_value_cstr(&breakpoint_path);

        // If tracepoint_lineno given, check both file path and lineno.
        // Otherwise only check file path.
        if (c_tracepoint_lineno >= 0) {
            VALUE breakpoint_lineno = rb_funcall(breakpoint, rb_intern("line"), 0);
            int c_breakpoint_lineno = NUM2INT(breakpoint_lineno);
            if ((c_tracepoint_lineno == c_breakpoint_lineno) && (strcmp(c_tracepoint_path, c_breakpoint_path) == 0)) {
                return breakpoint;
            }

        } else if (strcmp(c_tracepoint_path, c_breakpoint_path) == 0) {
            return breakpoint;
        }
    }

    return Qnil;
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
    VALUE match_found = match_breakpoints(self, tracepoint_path, Qnil);

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

    match_found = match_breakpoints(self, caller_path, Qnil);

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
    VALUE matching_breakpoint;
    VALUE self = (VALUE) data;
    VALUE breakpoint_manager = rb_iv_get(self, "@breakpoint_manager");

    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_path = rb_tracearg_path(tracepoint_arg);
    VALUE tracepoint_lineno = rb_tracearg_lineno(tracepoint_arg);
    VALUE tracepoint_binding;
    VALUE call_stack_bindings;
    VALUE all_complete;

    matching_breakpoint = match_breakpoints(self, tracepoint_path, tracepoint_lineno);
    if (RTEST(matching_breakpoint)) {
        rb_funcall(breakpoint_manager, rb_intern("complete_breakpoint"), 1, matching_breakpoint);
        tracepoint_binding = rb_tracearg_binding(tracepoint_arg);
        call_stack_bindings = rb_funcall(tracepoint_binding, rb_intern("callers"), 0);
        rb_ary_pop(call_stack_bindings);

        rb_funcall(matching_breakpoint, rb_intern("eval_call_stack"), 1, call_stack_bindings);

        all_complete = rb_funcall(breakpoint_manager, rb_intern("all_complete?"), 0);
        if (RTEST(all_complete))
            rb_disable_tracepoints(self);
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

    printf("Init_tracer called!\n");
    fflush(stdout);
}
