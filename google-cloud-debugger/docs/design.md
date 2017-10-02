# Stackdriver Debugger Agent Design Doc

The `google-cloud-debugger` instruments Stackdriver Debugger service in Ruby 
applications by implementing a Debugger Agent, which is able to communicate
with backend service to fetch user defined breakpoints and facilitate the
breakpoints evaluation in running Ruby applications. This document explains the 
design of the agent, how it works, and some rationale behind the design 
decisions.

## General workflow

A typical Stackdriver Debugger workflow starts with a debugger agent registers
itself and the application upon application startup. The registered debuggee
application/service will become avaiable on the [Stackdriver
 Debugger console](http://console.cloud.google.com/debug). Then user can select
application source code, if not automatically selected, and create breakpoints
on the UI. These breakpoints will be automatically distributed to all the 
debugger agents registered under this same service. The agents then turn on the
built-in tracing machanism to monitor the running applications. If any
application instance triggers the code with breakpoint defined, the breakpoints 
will be evaluated without affecting the running application, and the data 
will be sent back to the backend service and displayed on the Debugger UI. 
When all the breakpoints are evaluated or expired, the debugger agent will 
deactivate the program tracing.

## Architecture

The Stackdriver Debugger agent uses two child threads to handle communication 
with backend Stackdriver Debugger service. One thread for long polling 
breakpoints and one thread for submitting evaluated breakpoint data. The local 
breakpoints are managed by a shared Breakpoint Manager object and they are 
traced by using using Ruby VM Tracing API at C level.

![google-cloud-debugger agent 
design](google-cloud-debugger-agent-design.svg "Debugger Agent Design")

## Agent Components

* [Debuggee Application](#debuggee-and-debuggee-registration): The application that's 
registered with the Stackdriver Debugger service to be debuggeed.
* [Breakpoint](#breakpoints): An indicator that points to a location 
in the debuggee application source code. The debugger agent can collect program
state data or write logs when the code executes to the location with a 
breakpoint.
* [Breakpoint Polling](#breakpoint-polling): Long polling for breakpoints
created on the Stackdriver Debugger service.
* [Breakpoint Manager](#breakpoint-manager): A shared object that gets 
breakpoints from Stackdriver Debugger service and keeps trackk of all the 
breakpoints through out debugging process.
* [Breakpoint Tracer](#breakpoint-tracer): Traces debuggee program executing and
invoke breakpoint evaluation when breakpoints are triggered.
* [Breakpoint Validator](#breakpoint-validation): Verifies the location of where
the breakpoints are set.
* [Breakpoint Evaluator](#breakpoint-evaluation): Collects debuggee program 
state data and evaluates user defined expressions at the time of breakpoint
execution.
* [Breakpoint Transmitter](#breakpoint-transmitter): Submits evaluated
breakpoints back to the Stackdriver Debugger service.
* [Logger](#logger-and-log-entries): Used to log the outputs from the triggered
logpoints.

### Debuggee and Debuggee Registration

The debugger agent's `Google::Cloud::Debugger::Debuggee` class represents the
Ruby application that's being debugged, and it handles registration with backend
Stackdriver Debugger service whenever the debugger agent starts.

Given the nature of cloud hosting on Google Cloud Platform or other similar 
cloud hosting platforms, the same version application may be running on multiple 
servers or VMs. Therefore, all of such applications of the same version need 
to be registered with the Stackdriver Debugger service under the same service
identifier, so the breakpoints set for this application can be correctly
distributed to all running instances. The `Debuggee` class helps by generating
a unique SHA identifier from the source code in the application directory. See
the `Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator` class for more
details.

Upon successful registration, the backend Stackdriver Debugger service will 
assign a shared debuggee ID to all the application instances, which is used for
all further communication between the debugger agents and backend service.
Through-out the debuging process, the registration will be revoked whenever
there's error polling breakpoints from the backend service, and the debugger
agent will need to re-register before continuing any debugging. Note during
breakpoint polling, the backend service may also suddenly return a different 
debuggee ID as a way to renew the registration.

The debuggee registration also submits the `source-context.json` file if it's
available. This file is for the Stackdriver Debugger UI to match debuggee
application with source code stored on Cloud Source Repository. See the 
Stackdriver Debugger 
[doc](https://cloud.google.com/debugger/docs/source-context) on this matching 
works.

### Breakpoints

Unlike traditional debugging tools, users don't create breakpoints 
locally. Instead, breakpoints are created on the [Stackdriver Debugger
UI](http://console.cloud.google.com/debug) for registered debuggee services,
which then distributes the breakpoints to all the registered debuggee 
applications under that service. Once a debugger agent gets the breakpoint, it
will start tracing the debuggee application. When the application runs a line of
code with a breakpoint, it will pause the program and evaluate the breakpoint,
before resuming execution of that line and the rest of the program.

The Stackdriver Debugger product offers two kinds of breakpoint, snapshot point
(snappoint for short) and logpoint. When a snappoint is triggered, it collects
program state data, such as local variables, call stack, user defined
expression, at the time of execution. Once evaluated, a snappoint is
deactivated. On the other hand, logpoints are active for 24 hours after 
creation, if users don't delete them before expiration. When triggered, a
logpoint will log a user defined statement with possible formatted expressions
everytime the program executes the code with a logpoint. 

### Breakpoint Polling

The Stackdriver Debugger API uses a long polling mechanism to send breakpoints
information to registered debugger agents. So the debugger agents have to do
this asynchronously in a child thread, so the application thread isn't blocked
while the polling request is hung by the backend service. The polling requests 
refreshes every 40 seconds if no updates on the breakpoints. Whenever a new 
breakpoint is created or delete from the backend Stackdriver Debugger service, 
or evaluated by another application instance, the polling request would return 
immediately with the latest breakpoints data.

The backend Stackdriver Debugger service may also purposely revoke debuggee
registration by returning errorous status on the polling request. So unless
the polling requests expire on their own or returned with breakpoints data, the
agent needs to re-register the debuggee again to get future updates.

### Breakpoint Manager

The Breakpoint manager is responsbile for polling the backend Stackdriver
Debugger service for breakpoints, while keeping the true record of all the
breakpoints being worked by the debugger agent. 

The polling requests return the full set of breakpoints everytime. Even the
evaluated, but not yet reported ones. So it's up to the breakpoint manager to
track which breakpoints are being created or deleted, or already completed.

### Breakpoint Tracer

The Breakpoint Tracer/Tracing is built on top of the Ruby VM’s TracePoint 
feature and Ruby VM debug API. The TracePoint feature and Ruby debug API allow 
custom callback to be registered on certain events from Ruby VM level. For 
example, we can register custom callbacks every time the Ruby VM enters a new 
function, call a new block, call a line of code, etc. Once enabled, the tracing 
can be applied to all threads, while easily controlled in main thread.

When a watched event happens, the original program execution is halted and 
callback function is invoked within the same thread. The callback function gets 
a TracePoint object that contains event type, file path, line number, and 
context binding object. We can then compare the TracePoint file path and line 
number with our breakpoints’ file paths and line numbers to determine if we’ve 
hit a breakpoint.

For performance reason, we implement the Breakpoint Tracer using a more complex 
algorithm involving multiple Ruby TracePoints and debug API usage, instead of 
just using one TracePoint that checks every line of Ruby code executed.

#### File Tracing

When the debugger agent tracer starts, it creates a TracePoint (referred to 
below as the “file TracePoint”), which checks the executing file’s path against 
all the breakpoints’ file paths every time the program counter enters a new 
file. The program counter may switch file due to function call, class 
definition, or block yield. Once the program counter enters a file that contains
a breakpoint, the TracePoint callback enables line tracing. Otherwise it 
disables the line tracing to optimize performance.

#### Line Tracing

Since the line tracing functionality needs to be turned on and off often 
throughout threads executions, it’s directly implemented using the Ruby debug 
API, which is able to register line event hook for a single thread. This allows 
the debugger agent to control interference among the running threads and improve
performance in a multithreaded application. When the line event hook is 
registered, it invokes a callback on every line of Ruby code executed, which 
compares the current file path and execution line number with those of the 
breakpoints’. If we have a match, it identifies a breakpoint has been hit,
creates a context binding object on the spot, and triggers evaluation procedure
on that breakpoint. See “Breakpoint Evaluation” section below for details.

#### Interleaving and Return Tracing

It’s often possible the program jumps to a different method in different file 
in middle of a function body. If the new file doesn’t have any breakpoints, the 
line tracing will be disabled and won’t be re-enabled upon returning from that 
file. This interleaving scenario may happen right above the breakpoint, and we 
need to ensure the line tracing is on whenever the program counter is returned 
to the correct file. We solve this interleaving problem by registering another 
watch on return events (which we call the “return tracing”) the first time we 
encounter a breakpoint. The return tracing registers a callback on function 
return, class definition return, and block exit. It checks caller stack frame’s 
file path and correctly turn line tracing back on when the program counter 
returns to a file that contains breakpoints.

#### Fiber Switch Tracing

For the unique behavior of the Ruby VM’s fiber switching event, which is 
triggered on the calling line instead of in the fiber definition block, we 
dedicate a TracePoint (referred below as “fiber TracePoint”) just to trace fiber 
switching. The fiber TracePoint is enabled when tracer starts, similar to the 
file TracePoint. Every time a fiber switch happens, the callback will just 
blindly enable line tracing for the thread to make sure we don’t miss any 
breakpoints during the switch.

#### Example
The following diagram illustrates how file TracePoint, return TracePoint, 
and line tracing work together in a basic interleaving situation:

![google-cloud-debugger tracer
flow](google-cloud-debugger-tracer.svg "Debugger Tracer Flow Diagram")

In this figure, the breakpoint is set on breakpoint.rb, line 3. The File 
TracePoint is responsible for turning on/off the line TracePoint and return 
TracePoint. The return TracePoint ensures the line TracePoint is on after 
function interleaving. The line TracePoint eventually spots the breakpoint and 
trigger evaluation procedure.

### Breakpoint Validation

As you've learned from the [breakpoint tracing](#breakpoints-tracer) section,
the breakpoints are only reachable when defined on lines that are executed by
Ruby VM. So breakpoints set on invalid lines, such as blank lines or lines with 
comments, will never be triggered by the debugger agent. The breakpoint
validator helps filtering out common unreachable breakpoints by validating the 
locations of incoming breakpoints. For new breakpoints that are set on blank
lines or comments lines, the validator will immediately set the breakpoint to 
error status and return to backend Stackdriver Debugger service, so users will
instantly get an invalid breakpoint location warning.

### Breakpoint Evaluation

Breakpoints are evaluated by the debugger agent within the context of where they
are defined after being triggered. A snappoint type would be evaluated to
capture program state data at that point of execution; versus a logpoint simply
logs a formatted string to Stackdriver Logging.

#### Program state collection

Snappoints collect the local variables, stack trace, and user defined expression
evaluation results. To do this, the evaluation uses the `binding_of_caller` gem to 
get a list of Ruby `Binding` objects, one for each frame in the call
stack. Then retrieves local variables and stack frame data from the binding
objects. We only gets local variables for the top 5 most recent stack
frames, assuming those will be the commonly used data for user, and it's
not often useful to collect local variables for all the frames. The user defined
expressions are evaluated using the [readonly expression 
evaluation](#readonly-expression-evaluation) technique described below.

#### Variable conversion

All the variables and expression results we collect from the program will be
converted to a generic gRPC Variable representation before submitted to backend
service.

Thanks to Ruby's `#inspect` convention, we simply invoke `#inspect` on all the
simple objects, which are those not of class `Array` or `Hash`, and don't have
any instance variables. However, we truncate the result string to limit the
size.

The other more complex compound variables need to be converted recurrsively to 
include their child members. However, we only evaluate up to 3 levels deep. 
Elements at the 3rd level will be converted using `#inspect` method. Complex 
compound variables collected for snappoints and their compound children
variables are stored in a shared variable table in order to reduce memory 
footprint if they are referenced multiple times.

We have a size limit on total bytes of variables we collect. Each local 
variable and user defined expression result also have individual size limits.
However, user defined expression results' limit is set very high, at same amount
as the total total collection size. So it is possible that a snappoint collects
only one large user defined expression and nothing else. The snappoints' 
variable tables all have a shared "Buffer full" warning variable as the first
element in the tables. Once the compound variables have exceeded the individual
limit, or collection have exceeded global limit, all the follow up variables 
will be just converted to pointer to point to this shared "Buffer full" 
variable.

#### Readonly Expression Evaluation

Evaluating user defined expressions is the most risky operation in debugger 
agent workflow that may alter the state of the program. We use a complex
algorithem to make sure expression evaluations don't change the program
state or make any write operations.

The expressions are first compiled into op-codes using the 
`RubyVM::InstructionSequence` class. We then scan all the operations for
anything that may change program state, such as `setglobal`, `setclassvariable`,
`leave`, etc. If we find any prohibited operations, we prevent this expession from
being executed and set it to show a warning message. This steps checks
the immediate operations defined in the expressions, but not the operations
defined in other parts of program invoked through function calls from the
expressions. To make sure only the readonly functions are invoked through by
the breakpoint expressions, we wrap the expressions in more `TracePoint` on
Ruby or C function calls, then `eval` the wrapped code in an isolated thread.
For every Ruby functions called during the evaluation, we compile the body
of the function to op-codes and do the same security scan from above. If
any of the functions has state altering operations, we terminate the entire
evaluation from continuing. For C functions called, we're not able to check
the function bodies. So we keep a conservative whitelist of all the C functions
allowed. Before each of the C function is executed, we compare the method name
and defined class against our whitelist to make sure it's safe. Otherwise we
reject the whole evaluation.

Since we're doing the evaluation in separate threads. We can also limit the
amount of time they take. We terminate long running evaluations assuming
they either run into an infinite loop or they're doing heavy calculation,
both are bad ideas to perform in breakpoint evaluations.

### Logger and log entries

The debugger agent uses the logger implementation from the
`google-cloud-logging` gem. When logpoints are evaluated, the agent uses
the logger to send the log statements to Stackdriver Logging service.
The logpoints log entries are identical to the normal Stackdriver Logging
log entries, with the only exception of logpoints log messages begin with
a "LOGPOINT:" prefix.

In order to make the logpoints show up on Stackdriver Debugger UI, the 
agent also needs to add the Stackdriver Trace context ID into the log entries
if available. The Stackdriver Logging service uses the Trace context ID to 
correlate log entries with HTTP request information. Only the correlated 
logpoints log entries can be displayed on Stackdriver Debugger UI.

## Caveats

### State mutating inspects

For performance reason, we don't use the readonly evaluation techniques
when invoking the `#inspect` method calls on the collected local variables.
We trust all the Ruby objects are designed with the best practice in mind, where
the `#inspect` methods should always be readonly. But for the unfortunate few
that does mutate the program state in `#inspect` methods, it's up to the users
to refrain from using the Stackdriver Debugger wherever these variables are 
present.

### Extendable but slow breakpoint implementation

While most Stackdriver Debugger agents for other languages use binary or
op-code rewrite to implement the breakpoint feature, the Ruby Stackdriver 
Debugger uses the Ruby VM `TracePoint` and tracing API to mimic a breakpoint 
behavior. The best benefit of this approach is that the Ruby agent is one of 
the few, if not the only, extendable agents that's compatible with multiple 
versions of the programming language. The Ruby agent design works for Ruby v2.2+,
and all the future versions as long as the current tracing API is avariable.
The downside is that the `TracePoint` and tracing API are globally
affecting, so once they are turned on, they will slow down all the threads
in that Ruby process. But given the current algorithm, the performance overhead
is within tens of milliseconds.

### Unreachable Breakpoints

Since the breakpoints are implement using Ruby VM tracing line event 
callback, therefore, a breakpoint is only reachable if the line of code is 
actually executed by Ruby VM. The Breakpoint Validator class helps identifing 
the most common unreach cases, such as breakpoints set on blank lines and 
comment lines. But there are still other less common unreachable scenarios 
that the breakpoints won't be triggered, such as breakpoints set at middle 
of multi-line array or unncessary that get optimized out by Ruby compiler.
It's very difficult for the breakpoint validator to catch all the cases 
without reimplementing some VM features, so it's ultimately user's 
responsibility to make sure breakpoints are created on the lines of code 
are actually executed by Ruby VM.
