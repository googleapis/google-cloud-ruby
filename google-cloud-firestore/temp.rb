require "concurrent"

# thread_pool = Concurrent::ThreadPoolExecutor.new max_threads: 100000, max_queue: 0
#
# completion_event = Concurrent::Event.new
#
# (1..40000).each do |i|
#   Concurrent::Promises.future_on thread_pool, i do |i|
#     begin
#         puts "Running #{i}"
#         sleep(1)
#         puts "Completed #{i}"
#     rescue e
#       puts e
#     end
#   end
# end
#
# while true
#   sleep 1
#   puts Thread.list.count
# end
#
# completion_event.set
#
# sleep 1
#
# puts "Completed the program"



def call
  begin
    puts "here 2"
    raise ArgumentError.new "Error while running"
  rescue StandardError => e
    puts e
    raise e
  end
end


future = Concurrent::Promises.future do
  begin
    puts "herer"
    call
  rescue StandardError => e
    puts e
  end
end

future.wait!