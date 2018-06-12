require "pty"

commands = [
  "rvm-exec 2.5.1 bundle update; rvm-exec 2.5.1 bundle exec rake circleci:post",
  "rvm-exec 2.4.4 bundle update; rvm-exec 2.4.4 bundle exec rake test:coveralls"
]

node_index = Integer ENV["CIRCLE_NODE_INDEX"]
node_total = Integer ENV["CIRCLE_NODE_TOTAL"]

commands.each_with_index do |command, index|
  # only run the commands that are for the current node
  if node_index == index % node_total
    begin
      PTY.spawn(command) do |stdout, _stdin, pid|
        begin
          stdout.each_char { |c| print c }
        rescue Errno::EIO
        end
        Process.wait(pid)
      end
      status = $?.exitstatus
      exit status if status && status != 0
    rescue PTY::ChildExited
      puts "The test process exited."
    end
  end
end
