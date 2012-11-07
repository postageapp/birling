class Birling::Log < File
  # == Constants ============================================================

  # == Class Methods ========================================================

  def self.open(log, mode = nil)
    case (log)
    when IO
      yield(log) if (block_given?)
      
      log
    when String
      io = new(log, mode || 'a')
    
      yield(io) if (block_given?)
    
      io
    end
  end
  
  # == Instance Methods =====================================================
  
  def size
    self.stat.size
  end
  
  def create_time
    self.stat.ctime
  end
  
  def age(relative_to = nil)
    (relative_to || Time.now) - self.stat.ctime
  end
end
