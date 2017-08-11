module ApplicationHelper
  def wait_until
    delay = 2
    while delay <= 11
      sleep delay
      result = yield
      return result if result
      delay += 1
    end
    nil
  end
end
