#include "ruby/ruby.h"
#include "tracer.h"

//static VALUE file_tracepoint = Qnil;
//static VALUE line_tracepoint = Qnil;
//static VALUE breakpoint_manager = Qnil;

static void
disable_tracepoints(VALUE self)
{
    VALUE file_tracepoint = rb_iv_get(self, "@file_tracepoint");
    VALUE line_tracepoint = rb_iv_get(self, "@line_tracepoint");

    if (RTEST(file_tracepoint) && RTEST(rb_tracepoint_enabled_p(file_tracepoint)))
        rb_tracepoint_disable(file_tracepoint);
    if (RTEST(line_tracepoint) && RTEST(rb_tracepoint_enabled_p(line_tracepoint)))
        rb_tracepoint_disable(line_tracepoint);
}

static VALUE
rb_stop(VALUE self)
{
    disable_tracepoints(self);

    return Qnil;
}

static void
file_tracepoint_callback(VALUE tracepoint, void *data)
{
    int i;
    int match_found = 0;
    VALUE self = (VALUE) data;
    VALUE breakpoint_manager = rb_iv_get(self, "@breakpoint_manager");
    VALUE line_tracepoint = rb_iv_get(self, "@line_tracepoint");

    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_path = rb_tracearg_path(tracepoint_arg);
    char *c_tracepoint_path = rb_string_value_cstr(&tracepoint_path);

    VALUE active_breakpoints = rb_funcall(breakpoint_manager, rb_intern("active_breakpoints"), 0);
    VALUE *c_active_breakpoints = RARRAY_PTR(active_breakpoints);
    int active_breakpoints_len = RARRAY_LEN(active_breakpoints);

    for(i = 0; i < active_breakpoints_len; i ++) {
        VALUE breakpoint = c_active_breakpoints[i];
        VALUE breakpoint_path = rb_funcall(breakpoint, rb_intern("path"), 0);
        char *c_breakpoint_path = rb_string_value_cstr(&breakpoint_path);

        if (strcmp(c_tracepoint_path, c_breakpoint_path) == 0) {
            match_found = 1;
            break;
        }
    }

    if (match_found && RTEST(line_tracepoint) && !RTEST(rb_tracepoint_enabled_p(line_tracepoint))) {
        rb_tracepoint_enable(line_tracepoint);
    }
    else if (RTEST(line_tracepoint) && RTEST(rb_tracepoint_enabled_p(line_tracepoint))) {
        rb_tracepoint_disable(line_tracepoint);
    }

    return;
}

static void
line_tracepoint_callback(VALUE tracepoint, void *data)
{
    int i;
    VALUE self = (VALUE) data;
    VALUE breakpoint_manager = rb_iv_get(self, "@breakpoint_manager");

    rb_trace_arg_t *tracepoint_arg = rb_tracearg_from_tracepoint(tracepoint);
    VALUE tracepoint_path = rb_tracearg_path(tracepoint_arg);
    VALUE tracepoint_lineno = rb_tracearg_lineno(tracepoint_arg);
    char *c_tracepoint_path = rb_string_value_cstr(&tracepoint_path);
    int c_tracepoint_lineno = NUM2INT(tracepoint_lineno);

    VALUE active_breakpoints = rb_funcall(breakpoint_manager, rb_intern("active_breakpoints"), 0);
    VALUE *c_active_breakpoints = RARRAY_PTR(active_breakpoints);
    int active_breakpoints_len = RARRAY_LEN(active_breakpoints);

    for(i = 0; i < active_breakpoints_len; i++) {
        VALUE breakpoint = c_active_breakpoints[i];
        VALUE breakpoint_path = rb_funcall(breakpoint, rb_intern("path"), 0);
        VALUE breakpoint_lineno = rb_funcall(breakpoint, rb_intern("line"), 0);
        char *c_breakpoint_path = rb_string_value_cstr(&breakpoint_path);
        int c_breakpoint_lineno = FIX2INT(breakpoint_lineno);
        VALUE tracepoint_binding;
        VALUE call_stack_bindings;
        VALUE all_complete;

        if ((c_tracepoint_lineno == c_breakpoint_lineno) && (strcmp(c_tracepoint_path, c_breakpoint_path) == 0)) {
            rb_funcall(breakpoint_manager, rb_intern("complete_breakpoint"), 1, breakpoint);
            tracepoint_binding = rb_tracearg_binding(tracepoint_arg);
            call_stack_bindings = rb_funcall(tracepoint_binding, rb_intern("callers"), 0);
            rb_ary_pop(call_stack_bindings);

            rb_funcall(breakpoint, rb_intern("eval_call_stack"), 1, call_stack_bindings);

            all_complete = rb_funcall(breakpoint_manager, rb_intern("all_complete?"), 0);
            if (RTEST(all_complete))
                disable_tracepoints(self);
        }
    }

    return;
}

static VALUE
register_file_tracepoint(VALUE self)
{
    VALUE file_tracepoint = rb_iv_get(self, "@file_tracepoint");

    if (!RTEST(file_tracepoint)) {
        file_tracepoint = rb_tracepoint_new(Qnil, RUBY_EVENT_CALL | RUBY_EVENT_CLASS, file_tracepoint_callback, (void *)self);
        rb_iv_set(self, "@file_tracepoint", file_tracepoint);
    }

    return file_tracepoint;
}

static VALUE
register_line_tracepoint(VALUE self)
{
    VALUE line_tracepoint = rb_iv_get(self, "@line_tracepoint");

    if (!RTEST(line_tracepoint)) {
        line_tracepoint = rb_tracepoint_new(Qnil, RUBY_EVENT_LINE, line_tracepoint_callback, (void *)self);
        rb_iv_set(self, "@line_tracepoint", line_tracepoint);
    }

    return line_tracepoint;
}

static VALUE
rb_start(int argc, VALUE* argv, VALUE self)
{
//    VALUE caller_file_path;
//    rb_scan_args(argc, argv, "10", &caller_file_path);

    // Initialize tracepoints and get breakpoint_manager
    VALUE file_tracepoint = register_file_tracepoint(self);
    register_line_tracepoint(self);
//    breakpoint_manager = rb_iv_get(self, "@breakpoint_manager");

    // Immediately activate file tracepoint

    if (!RTEST(rb_tracepoint_enabled_p(file_tracepoint)))
        rb_tracepoint_enable(file_tracepoint);

    return Qnil;
}

void
Init_tracer(VALUE mDebugger)
{
    VALUE cTracer = rb_define_class_under(mDebugger, "Tracer", rb_cObject);

    rb_define_method(cTracer, "start", rb_start, -1);
    rb_define_method(cTracer, "stop", rb_stop, 0);

    printf("Init_tracer called!\n");
    fflush(stdout);
}
