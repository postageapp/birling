class Birling
  # == Submodules ===========================================================
  
  autoload(:Formatter, 'birling/formatter')
  autoload(:Logger, 'birling/logger')
  autoload(:Support, 'birling/support')
  
  # == Module Methods =======================================================
  
  # Opens a new log file at the given path with options:
  # * encoding: The encoding of the file (default: 'UTF8')
  # * period: The rotation period to use (optional)
  # * retain_count: How many log files to retain when rotating (optional)
  # * retain_period: How long rotated log files are retained for (optional)
  # * formatter: Custom log formatter (optional)
  # * program: Name of program being logged (optional)
  # * time_source: Source of time to use (optional)
  # * path_format: The strftime-compatible format for the path (optional)
  def self.open(path, options = nil)
    Birling::Logger.new(path, options)
  end
end
