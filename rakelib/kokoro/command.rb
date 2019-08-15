require "open3"
require "timeout"

class Command
  def initialize
    @failed = false
  end

  def run command, timeout = 0
    if timeout > 0
      run_command_with_timeout command, timeout
    else
      run_command command
    end
    !@failed
  end

  private

  def run_command command
    out, err, st = Open3.capture3 command
    puts out
    if st.to_i != 0
      puts err
      @failed = true
    end
  end

  def run_command_with_timeout
    job = Process.spawn command
    begin
      Timeout.timeout timeout do
        Process.wait job
      end
      return $?.exitstatus
    rescue Timeout::Error
      header_2 "TIMEOUT - #{timeout / 60} minute limit exceeded."
      Process.kill "TERM", job
    end
    @failed = true
  end
end
