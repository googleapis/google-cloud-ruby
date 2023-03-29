require "concurrent"

thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: 5,  max_queue: 30000, idle_time: 1

completion_event = Concurrent::Event.new

(1..50).each do |i|
  Concurrent::Promises.future_on thread_pool, i do |i|
    begin
      while true
        puts "Running #{i}"
        if completion_event.wait
          puts "Completed #{i}"
          break
        end
      end
    rescue e
      puts e
    end
  end
end

sleep 10

completion_event.set

sleep 1

puts "Completed the program"




