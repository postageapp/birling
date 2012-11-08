class Birling::Logger
  # == Constants ============================================================
  
  # These level constants are the same as the syslog system utility
  SEVERITY = {
    :emergency => EMERGENCY = 0,
    :alert => ALERT = 1,
    :critical => CRITICAL = 2,
    :error => ERROR = 3,
    :warning => WARNING = 4,
    :notice => NOTICE = 5,
    :info => INFO = 6,
    :debug => DEBUG = 7,
    :unknown => UNKNOWN = 999
  }.freeze
  
  DEFAULT_SEVERITY = UNKNOWN

  SEVERITY_LABEL = SEVERITY.invert.freeze
  
  PATH_TIME_DEFAULT = {
    :hourly => '%Y%m%d%H'.freeze,
    :daily => '%Y%m%d'.freeze,
    :default => '%s'.freeze
  }.freeze
  
  # == Properties ===========================================================

  attr_reader :severity
  attr_accessor :formatter
  attr_accessor :program
  attr_accessor :time_source
  attr_reader :path
  attr_reader :path_format
  attr_reader :path_time_format
  attr_reader :current_path
  attr_reader :retain_count
  attr_reader :retain_period
  attr_reader :period
  attr_reader :rotation_time
  
  # == Class Methods ========================================================
  
  def self.severity(value)
    case (value)
    when Symbol
      SEVERITY[value] or DEFAULT_SEVERITY
    when String
      SEVERITY[value.to_sym] or DEFAULT_SEVERITY
    when Fixnum
      SEVERITY_LABEL[value] and value or DEFAULT_SEVERITY
    else
      DEFAULT_SEVERITY
    end
  end
  
  # == Instance Methods =====================================================

  def initialize(log, options = nil)
    @period = (options and options[:period])
    @severity = self.class.severity(options && options[:severity])
    @retain_count = (options and options[:retain_count])
    @retain_period = (options and options[:retain_period])
    @formatter = (options and options[:formatter] or Birling::Formatter)
    @program = (options and options[:program] or nil)
    @time_source = (options and options[:time_source] or Time)
    @path_format = (options and options[:path_format])

    case (log)
    when IO, StringIO
      @log = log
    when String
      @path = log
    end
      
    if (@path and @period)
      @rotation_time = self.next_rotation_time
      
      @path_time_format = (PATH_TIME_DEFAULT[@period] or PATH_TIME_DEFAULT[:default])
      
      @path_format ||=
        @path.sub(/\.(\w+)$/) do |s|
          '.' + @path_time_format + '.' + $1
        end
    end
    
    if (@path and !@log)
      self.log_open!
    end
  
    yield(self) if (block_given?)
  end
  
  def severity=(value)
    @severity = self.class.severity(value)
  end
  
  def can_rotate?
    !!@path
  end
  
  def size
    @log and @log.respond_to
  end
  
  def retain=(value)
    @retain = value ? value.to_i : nil
    
    if (@retain_period and @retain_period <= 0)
      @retain_period = nil
    end
    
    @retain_period
  end
  
  def log(level, message = nil, program = nil)
    return unless (@log)
    
    level = self.class.severity(level)
    program ||= @program

    self.check_log_rotation!
    
    @log.write(@formatter.call(level, @time_source.now, program, message))
  end
  alias_method :add, :log

  def <<(message)
    return unless (@log)
    
    self.check_log_rotation!
    
    @log.write(message)
  end
  
  SEVERITY.each do |name, level|
    define_method(:"#{name}?") do
      @severity >= level
    end
    
    define_method(name) do |message = nil, program = nil|
      return unless (@log and @severity >= level)
      
      program ||= @program
      
      if (!message and block_given?)
        message = yield
      end

      self.check_log_rotation!

      @log.write(@formatter.call(level, @time_source.now, program, message))
    end
  end

  def close
    return unless (@log)
    
    @log.close
    @log = nil
  end
  
  def opened?
    !!@log
  end

  def closed?
    !@log
  end

  def create_time
    @log and @log.ctime
  end
  
  def size
    @log and @log.size
  end
   
  def age(relative_to = nil)
    (relative_to || @time_source.now) - @log.ctime
  end
  
protected
  def next_rotation_time
    case (@period)
    when Fixnum, Float
      @time_source.now + @period
    when :daily
      Birling::Support.next_day(@time_source.now)
    when :hourly
      Birling::Support.next_hour(@time_source.now)
    else
      nil
    end
  end
  
  def prune_logs!
    return unless (@path and (@retain_period or @retain_count))
    
    log_spec = @path.sub(/\.(\w+)$/, '*')
    
    logs = (Dir.glob(log_spec) - [ @path ]).collect do |p|
      stat = File.stat(p)
      create_time = (stat and stat.ctime or @time_source.now)
      
      [ p, create_time ]
    end.sort_by do |r|
      r[1] || @time_source.now
    end
    
    if (@retain_period)
      logs.reject! do |r|
        if (Time.now - r[1] > @retain_period)
          FileUtils.rm_f(r[0])
        end
      end
    end
    
    if (@retain_count)
      # The logs array is sorted from oldest to newest, so retaining the N
      # newest entries entails stripping them off the end with pop.

      logs.pop(@retain_count)
      
      FileUtils.rm_f(logs.collect { |r| r[0] })
    end
  end
  
  def check_log_rotation!
    return unless (@rotation_time)
    
    if (@time_source.now >= @rotation_time)
      self.log_open!
      
      @rotation_time = self.next_rotation_time
    end
  end

  def log_open!
    if (@path_format)
      @current_path = @time_source.now.strftime(@path_format)
      
      @log = File.open(@current_path, 'a')
      @log.sync = true
      
      if (File.exist?(@path) and File.symlink?(@path))
        File.unlink(@path)
      end

      unless (File.exist?(@path))
        File.symlink(@current_path, @path)
      end
      
      self.prune_logs!
    else
      @current_path = @path
      
      @log = File.open(@current_path, 'a')
    end
  end
end
