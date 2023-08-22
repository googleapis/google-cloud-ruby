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
#include "debugger.h"

static VALUE mGoogle, mCloud, mDebugger;

void
Init_debugger_c()
{
    mGoogle = rb_define_module("Google");
    mCloud = rb_define_module_under(mGoogle, "Cloud");
    mDebugger = rb_define_module_under(mCloud, "Debugger");

    Init_tracer(mDebugger);
    Init_evaluator(mDebugger);
}
