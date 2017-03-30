# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "helper"
require_relative "expression_test_helper"

describe Google::Cloud::Debugger::Breakpoint::Evaluator do
  let(:evaluator) { Google::Cloud::Debugger::Breakpoint::Evaluator }

  describe "Array" do
    it "allows #size" do
      expression_must_equal "[1,2,3].size", 3
    end

    it "allows #each" do
      expression_must_be_kind_of "[].each {}", Array
    end

    it "allows #+" do
      expression_must_equal "[1] + [2, 3]", [1, 2, 3]
    end

    it "doesn't allow #push" do
      expression_not_allowed "[].push 1"
    end

    it "doesn't allow #compact!" do
      expression_not_allowed "[nil].compact!"
    end
  end

  describe "BasicObject" do
    it "allows #__id__" do
      expression_must_be_kind_of "[].__id__", 1.class
    end

    it "doesn't allow #instance_eval" do
      expression_not_allowed "[].instance_eval { |a| a == self }"
    end
  end

  describe "Binding" do
    it "allows #local_variables" do
      expression_must_be_kind_of "binding.local_variables", Array
    end

    it "doesn't allow #eval" do
      expression_not_allowed "binding.eval ''"
    end
  end

  describe "Class" do
    it "allows #superclass" do
      expression_must_equal "Google::Cloud::Debugger::Breakpoint.superclass",
                            Object
    end

    it "doesn't allow #new" do
      expression_not_allowed "Class.new"
    end
  end

  describe "Dir" do
    it "allows #path" do
      dir = Dir.new ".."
      expression_must_equal "dir.path", "..", binding
    end

    it "doesn't allow #each" do
      dir = Dir.new ".."
      expression_not_allowed "dir.each", binding
    end
  end

  describe "Exception" do
    it "allows #backtrace" do
      expression_must_be_kind_of "Exception.new.backtrace", NilClass
    end

    it "doesn't allow #set_backtrace" do
      expression_not_allowed "Exception.new.set_backtrace []"
    end
  end

  describe "Enumerator" do
    it "allows #each" do
      expression_must_be_kind_of "[].each.each {}", Array
    end

    it "doesn't allow #next" do
      expression_not_allowed "[].each.next"
    end
  end

  describe "Fiber" do
    require "fiber"
    it "allows #alive?" do
      fiber = Fiber.new {}
      expression_must_equal "fiber.alive?", true, binding
    end

    it "doesn't allow #resume" do
      fiber = Fiber.new {}
      expression_not_allowed "fiber.resume", binding
    end
  end

  describe "File" do
    it "allows #path" do
      file = File.new __FILE__
      expression_must_equal "file.path", __FILE__, binding
    end

    it "doesn't allow #chmod" do
      file = File.new __FILE__
      expression_not_allowed "file.chmod 0777", binding
    end
  end

  describe "Hash" do
    it "allows #[]" do
      expression_must_equal "{a: 3}[:a]", 3
    end

    it "allows #empty?" do
      expression_must_equal "{}.empty?", true
    end

    it "allows #key?" do
      expression_must_equal "{a: 3}.key? :a", true
    end

    it "doesn't allow #delete" do
      expression_not_allowed "{}.delete :a"
    end

    it "doesn't allow #select!" do
      expression_not_allowed "{}.select! {}"
    end
  end

  describe "IO" do
    it "allows #autoclose?" do
      io = IO.new 1
      expression_must_equal "io.autoclose?", true, binding
    end

    it "doesn't allow #readlines" do
      io = IO.new 1
      expression_not_allowed "io.readlines", binding
    end
  end

  describe "Method" do
    it "allows #name" do
      expression_must_equal "[].method(:each).name", :each
    end

    it "doesn't allow #unbind" do
      expression_not_allowed "[].method(:each).unbind"
    end
  end

  describe "Mutex" do
    it "allows #locked?" do
      mutex = Mutex.new
      expression_must_equal "mutex.locked?", false, binding
    end

    it "doesn't allow #lock" do
      mutex = Mutex.new
      expression_not_allowed "mutex.lock", binding
    end
  end

  describe "String" do
    it "allows #length" do
      expression_must_equal "'abc'.length", 3
    end

    it "allows #chomp" do
      expression_must_equal '"abc\n".chomp', "abc"
    end

    it "allows #+" do
      expression_must_equal "'he' + 'llo'", "hello"
    end

    it "doesn't allow #reverse!" do
      expression_not_allowed "'abc'.reverse!"
    end

    it "doesn't allow capitalize!" do
      expression_not_allowed "'abc'.capitalize!"
    end
  end

  describe "ThreadGroup" do
    it "allows #list" do
      tg = ThreadGroup.new
      expression_must_be_kind_of "tg.list", Array, binding
    end

    it "doesn't allow #add" do
      tg = ThreadGroup.new
      thr = Thread.new {}
      expression_not_allowed "tg.add thr", binding
    end
  end

  describe "Thread" do
    it "allows #[]" do
      thr = Thread.new {}
      thr[:a] = 3
      expression_must_equal "thr[:a]", 3, binding
    end

    it "allows #alive?" do
      thr = Thread.new {}
      thr.join
      expression_must_equal "thr.alive?", false, binding
    end

    it "allows #status" do
      thr = Thread.new {}
      thr.join
      expression_must_equal "thr.status", false, binding
    end

    it "doesn't allow #exit" do
      thr = Thread.new {}
      expression_not_allowed "thr.exit", binding
    end

    it "doesn't allow #join" do
      thr = Thread.new {}
      expression_not_allowed "thr.join", binding
    end
  end

  describe "Time" do
    it "allows #+" do
      expression_must_be_kind_of "Time.now + 3", Time
    end

    it "allows #utc?" do
      utc = Time.now.utc?
      expression_must_equal "Time.now.utc?", utc
    end

    it "doesn't allow #utc" do
      expression_not_allowed "Time.now.utc"
    end

    it "doesn't allow #gmtime" do
      expression_not_allowed "Time.now.gmtime"
    end
  end

  describe "UnboundMethod" do
    it "allows #name" do
      meth = [].method(:size).unbind
      expression_must_equal "meth.name", :size, binding
    end

    it "doesn't allow #bind" do
      meth = [].method(:size).unbind
      expression_not_allowed "meth.bind []", binding
    end
  end

  describe "Kernel" do
    it "allows #lambda" do
      expression_must_be_kind_of "lambda {}", Proc
    end

    it "allows #local_variables" do
      expression_must_be_kind_of "local_variables", Array
    end

    it "allows #rand" do
      expression_must_be_kind_of "rand", Float
    end

    it "allows #instance_variable_get" do
      obj = Object.new
      obj.instance_variable_set :@a, 3
      expression_must_equal "obj.instance_variable_get :@a", 3, binding
    end

    it "allows #frozen?" do
      obj = Object.new
      expression_must_equal "obj.frozen?", false, binding
    end

    it "doesn't allow #instance_variable_set" do
      obj = Object.new
      expression_not_allowed "obj.instance_variable_set :@a, 3", binding
    end

    it "doesn't allow #exit" do
      expression_not_allowed "exit"
    end

    it "doesn't allow #fail" do
      expression_not_allowed "fail"
    end

    it "doesn't allow #fork" do
      expression_not_allowed "fork"
    end

    it "doesn't allow #raise" do
      expression_not_allowed "raise"
    end

    it "doesn't allow #sleep" do
      expression_not_allowed "sleep"
    end

    it "doesn't allow #system" do
      expression_not_allowed "system"
    end

    it "doesn't allow #`" do
      expression_not_allowed "`ls`"
    end

    it "doesn't allow #eval" do
      expression_not_allowed "eval '[]'"
    end

    it "doesn't allow #exec" do
      expression_not_allowed "exec 'ls'"
    end
  end
end
