class Birling
  # == Submodules ===========================================================
  
  autoload(:Formatter, 'birling/formatter')
  autoload(:Logger, 'birling/logger')
  autoload(:Support, 'birling/support')
  
  # == Module Methods =======================================================
  
  def self.open(path, options = nil)
    Birling::Logger.new(path, options)
  end
end
