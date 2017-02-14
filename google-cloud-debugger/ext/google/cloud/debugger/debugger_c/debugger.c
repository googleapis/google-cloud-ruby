#include "ruby/ruby.h"
#include "debugger.h"

static VALUE mGoogle, mCloud, mDebugger;

void
Init_debugger_c()
{
    mGoogle = rb_define_module("Google");
    mCloud = rb_define_module_under(mGoogle, "Cloud");
    mDebugger = rb_define_module_under(mCloud, "Debugger");
//    UNUSED(mDebugger);

    Init_tracer(mDebugger);

    printf("Init_debugger called!\n");
    fflush(stdout);
}
