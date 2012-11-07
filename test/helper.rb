require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'fileutils'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'birling'

class Test::Unit::TestCase
  def in_time_zone(zone)
    tz = ENV['TZ']
    
    ENV['tz'] = zone
    
    yield if (block_given?)
    
  ensure
    ENV['tz'] = tz
  end
  
  def temp_path(name = nil)
    name ||= begin
      @temp_path_inc ||= 0

      _name = '%05d.%05d.tmp' % [ @temp_path_inc, $$ ]
      @temp_path_inc += 1
      
      _name
    end
    
    case (name)
    when Symbol
      name = "#{name}.log"
    end
    
    @temp_path ||= File.expand_path('../tmp', File.dirname(__FILE__))
    
    full_path = File.expand_path(name, @temp_path)
    
    FileUtils::mkdir_p(File.dirname(full_path))
    
    if (block_given?)
      begin
        yield(full_path)
      ensure
        if (File.exist?(full_path))
          File.unlink(full_path)
        end
      end
    end
    
    full_path
  end
end
