module MultiTimeTrackerHelper

   def formatted_active_time(logging)
    seconds_at_all = logging.spent_seconds + (Time.now - logging.activated_at)
    t = Time.new(0) + seconds_at_all
    return (t.yday > 1 ? "#{t.yday}:#{t.strftime("%H:%M:%S")}" : t.strftime("%H:%M:%S"))
  end
  
  def formatted_time(logging)
    unless logging.activated_at.nil?
      t = Time.new(0) + logging.spent_seconds
      return (t.yday > 1 ? "#{t.yday}:#{t.strftime("%H:%M:%S")}" : t.strftime("%H:%M:%S"))
    end
    
    return "00:00:00"
  end
  
end
