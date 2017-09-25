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

#ifndef GOOGLE_CLOUD_RUBY_DEBUGGER_TRACER_H_
#define GOOGLE_CLOUD_RUBY_DEBUGGER_TRACER_H_

#include "ruby/debug.h"

#define FILE_TRACEPOINT_EVENTS (RUBY_EVENT_CLASS | RUBY_EVENT_CALL | RUBY_EVENT_B_CALL)
#define RETURN_TRACEPOINT_EVENTS (RUBY_EVENT_END | RUBY_EVENT_RETURN | RUBY_EVENT_B_RETURN)
#define FIBER_TRACEPOINT_EVENT RUBY_EVENT_FIBER_SWITCH

/* To prevent unused parameter warnings */
#define UNUSED(x) (void)(x)

void
Init_tracer(VALUE mDebugger);

#endif // GOOGLE_CLOUD_RUBY_DEBUGGER_TRACER_H_
