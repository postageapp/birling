module Birling::Support
  def next_day(time, time_source = nil)
    (time_source || Time).local(
      time.year,
      time.month,
      time.day,
      23,
      59,
      59
    ) + 1
  end
  
  def next_hour(time, time_source = nil)
    seconds_left = time.to_i % 3600
    
    time + (seconds_left > 0 ? seconds_left : 3600)
  end
    
  extend self
end
