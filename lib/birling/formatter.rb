require 'time'

module Birling::Formatter
  # == Constants ============================================================

  TIME_FORMAT_DEFAULT = '%Y-%m-%d %H:%M:%S'.freeze

  # == Module Methods =======================================================

  def self.time_format(time)
    (time || Time.now).strftime(TIME_FORMAT_DEFAULT)
  end

  def self.call(severity, time, program, message)
    if (program)
      "[#{time.strftime(TIME_FORMAT_DEFAULT)}] <#{program}> #{message}\n"
    else
      "[#{time.strftime(TIME_FORMAT_DEFAULT)}] #{message}\n"
    end
  end
end
