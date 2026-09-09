require "google/cloud/video/live_stream"

def event_def
  {
    ad_break: {
      duration: {
        seconds: 100
      }
    },
    execute_now: true
  }
end
