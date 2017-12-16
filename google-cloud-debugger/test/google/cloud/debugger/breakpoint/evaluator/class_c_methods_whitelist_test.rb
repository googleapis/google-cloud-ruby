# Copyright 2017 Google LLC
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

describe Google::Cloud::Debugger::Breakpoint::Evaluator do
  let(:evaluator) { Google::Cloud::Debugger::Breakpoint::Evaluator }

  describe "Array" do
    it "allows .new" do
      expression_must_be_kind_of "Array.new 2, nil", Array
    end
  end

  describe "BasicObject" do
    it "allows .new" do
      expression_must_be_kind_of "BasicObject.new", BasicObject
    end
  end

  describe "Exception" do
    it "allows .new" do
      expression_must_be_kind_of "Exception.new", Exception
    end
  end

  describe "Enumerator" do
    it "allows .new" do
      expression_must_be_kind_of "Enumerator.new {}", Enumerator
    end
  end

  describe "Fiber" do
    it "allows .current" do
      require "fiber"
      expression_must_be_kind_of "Fiber.current", Fiber
    end
  end

  describe "File" do
    it "allows .basename" do
      expression_must_equal "File.basename 'ruby.rb'", "ruby.rb"
    end

    it "allows .join" do
      expression_must_equal "File.join 'path', 'to', 'file.rb'",
                            "path/to/file.rb"
    end

    it "doesn't allow .exist? method" do
      expression_prohibited "File.exist? './file.rb'"
    end

    it "doesn't allow .size method" do
      expression_prohibited "File.size './file.rb'"
    end

    it "doesn't allow .open method" do
      expression_prohibited "File.open './file.rb'"
    end
  end

  describe "Hash" do
    it "allows .new" do
      expression_must_be_kind_of "Hash.new 'Hello'", Hash
    end
  end

  describe "Module" do
    it "allows .constants" do
      expression_must_be_kind_of "Module.constants", Array
    end
  end

  describe "Object" do
    it "allows .new" do
      expression_must_be_kind_of "Object.new", Object
    end
  end

  describe "String" do
    it "allows .new" do
      expression_must_be_kind_of "String.new", String
    end
  end

  describe "Thread" do
    it "allows .current" do
      expression_must_be_kind_of "Thread.current", Thread
    end

    it "allows .list" do
      expression_must_be_kind_of "Thread.list", Array
    end

    it "doesn't allow .new" do
      expression_prohibited "Thread.new {}"
    end

    it "doesn't allow .fork" do
      expression_prohibited "Thread.fork {}"
    end

    it "doesn't allow .exit" do
      expression_prohibited "Thread.exit"
    end
  end

  describe "Time" do
    it "allows .now" do
      expression_must_be_kind_of "Time.now", Time
    end

    it "allows .at" do
      skip if RUBY_VERSION.to_f < 2.4

      expression_must_be_kind_of "Time.at 0", Time
    end
  end
end
