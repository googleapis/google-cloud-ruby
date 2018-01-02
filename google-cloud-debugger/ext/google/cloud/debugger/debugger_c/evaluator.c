/*
    Copyright 2017 Google Inc. All rights reserved.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

#include "ruby/ruby.h"
#include "ruby/debug.h"
#include "evaluator.h"

static void
eval_trace_callback(void *data, rb_trace_arg_t *trace_arg)
{
    rb_event_flag_t event;
    VALUE evaluator;
    VALUE klass;
    VALUE obj;
    VALUE method_id;
    ID trace_func_cb_id;
    ID trace_c_func_cb_id;

    CONST_ID(trace_func_cb_id, "trace_func_callback");
    CONST_ID(trace_c_func_cb_id, "trace_c_func_callback");

    event = rb_tracearg_event_flag(trace_arg);
    evaluator = (VALUE)data;
    obj = rb_tracearg_self(trace_arg);
    method_id = rb_tracearg_method_id(trace_arg);
    klass = rb_tracearg_defined_class(trace_arg);

    if (event & RUBY_EVENT_CALL) {
        rb_funcall(evaluator, trace_func_cb_id, 3, obj, klass, method_id);
    }
    if (event & RUBY_EVENT_C_CALL) {
        rb_funcall(evaluator, trace_c_func_cb_id, 3, obj, klass, method_id);
    }

    return;
}

static VALUE
rb_disable_method_trace_for_thread(VALUE self)
{
    VALUE current_thread;
    VALUE thread_variables_hash;
    VALUE trace_set;
    ID locals_id;
    ID eval_trace_thread_id;
    VALUE eval_trace_thread_flag;

    CONST_ID(locals_id, "locals");
    CONST_ID(eval_trace_thread_id, "gcloud_eval_trace_set");
    eval_trace_thread_flag = ID2SYM(eval_trace_thread_id);

    current_thread = rb_thread_current();
    thread_variables_hash = rb_ivar_get(current_thread, locals_id);
    trace_set = rb_hash_aref(thread_variables_hash, eval_trace_thread_flag);

    if (RTEST(trace_set)) {
        rb_thread_remove_event_hook(current_thread, (rb_event_hook_func_t)eval_trace_callback);
        rb_hash_aset(thread_variables_hash, eval_trace_thread_flag, Qfalse);
    }

    return Qnil;
}

static VALUE
rb_enable_method_trace_for_thread(VALUE self)
{
    VALUE current_thread;
    VALUE thread_variables_hash;
    VALUE trace_set;
    VALUE evaluator;
    ID current_evaluator_id;
    ID locals_id;
    ID eval_trace_thread_id;
    VALUE eval_trace_thread_flag;

    CONST_ID(current_evaluator_id, "current");
    CONST_ID(locals_id, "locals");
    CONST_ID(eval_trace_thread_id, "gcloud_eval_trace_set");
    eval_trace_thread_flag = ID2SYM(eval_trace_thread_id);

    current_thread = rb_thread_current();
    thread_variables_hash = rb_ivar_get(current_thread, locals_id);
    trace_set = rb_hash_aref(thread_variables_hash, eval_trace_thread_flag);
    evaluator = rb_funcall(self, current_evaluator_id, 0);

    if (!RTEST(trace_set)) {
        rb_thread_add_event_hook2(current_thread, (rb_event_hook_func_t)eval_trace_callback, RUBY_EVENT_CALL | RUBY_EVENT_C_CALL, evaluator, RUBY_EVENT_HOOK_FLAG_RAW_ARG | RUBY_EVENT_HOOK_FLAG_SAFE);
        rb_hash_aset(thread_variables_hash, eval_trace_thread_flag, Qtrue);
    }

    return Qnil;
}

void
Init_evaluator(VALUE mDebugger)
{
    VALUE cBreakpoint = rb_define_class_under(mDebugger, "Breakpoint", rb_cObject);
    VALUE cEvaluator  = rb_define_class_under(cBreakpoint, "Evaluator", rb_cObject);

    rb_define_module_function(cEvaluator, "enable_method_trace_for_thread", rb_enable_method_trace_for_thread, 0);
    rb_define_module_function(cEvaluator, "disable_method_trace_for_thread", rb_disable_method_trace_for_thread, 0);
}
