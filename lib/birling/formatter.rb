module Birling::Formatter
  # == Constants ============================================================

  TIME_FORMAT_DEFAULT = '%Y-%m-%d %H:%M:%S'.freeze

  # == Module Methods =======================================================

  def self.call(severity, time, program, message)
    if (program)
      "[#{time.strftime(TIME_FORMAT_DEFAULT)}] <#{program}> #{message}"
    else
      "[#{time.strftime(TIME_FORMAT_DEFAULT)}] #{message}"
    end
  end
end
