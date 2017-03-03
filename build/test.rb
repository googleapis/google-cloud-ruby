require "pty"

commands = [
  "rvm-exec 2.4.0 bundle exec rake circleci:build",
  "rvm-exec 2.3.1 bundle exec rake circleci:build",
  "rvm-exec 2.2.5 bundle exec rake circleci:build",
  "rvm rubygems current; bundle exec rake circleci:build",
  "rvm-exec 2.0.0-p648 bundle exec rake circleci:build"
]

node_index = Integer ENV["CIRCLE_NODE_INDEX"]
node_total = Integer ENV["CIRCLE_NODE_TOTAL"]

commands.each_with_index do |command, index|
  # only run the commands that are for the current node
  if node_index == index % node_total
    begin
      status = PTY.spawn(command) do |stdout, _stdin, pid|
        begin
          stdout.each_char { |c| print c }
        rescue Errno::EIO
        end
        Process.wait(pid)
      end
      exit status if status != 0
    rescue PTY::ChildExited
      puts "The test process exited."
    end
  end
end
