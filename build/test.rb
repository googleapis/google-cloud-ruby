require "pty"

command_groups = [
  ["rvm-exec 2.5.1 gem install bundler",
   "rvm-exec 2.5.1 bundle update",
   "rvm-exec 2.5.1 bundle exec rake circleci:build"],
  ["rvm-exec 2.4.4 gem install bundler",
   "rvm-exec 2.4.4 bundle update",
   "rvm-exec 2.4.4 bundle exec rake circleci:build"],
  ["rvm-exec 2.3.7 gem install bundler",
   "rvm-exec 2.3.7 bundle update",
   "rvm-exec 2.3.7 bundle exec rake circleci:build"]
]

node_index = Integer ENV["CIRCLE_NODE_INDEX"]
node_total = Integer ENV["CIRCLE_NODE_TOTAL"]

command_groups.each_with_index do |commands, index|
  # only run the commands that are for the current node
  if node_index == index % node_total
    begin
      commands.each do |command|
        PTY.spawn(command) do |stdout, _stdin, pid|
          begin
            stdout.each_char { |c| print c }
          rescue Errno::EIO
          end
          Process.wait(pid)
        end
        status = $?.exitstatus
        exit status if status && status != 0
      end
    rescue PTY::ChildExited
      puts "The test process exited."
    end
  end
end
