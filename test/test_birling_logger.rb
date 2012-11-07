require File.expand_path('helper', File.dirname(__FILE__))

class TestBirlingLogger < Test::Unit::TestCase
  def test_defaults
    temp_path do |path|
      log = Birling::Logger.new(path)
    
      assert log

      assert log.opened?
      assert !log.closed?
      assert_equal 0, log.size
      assert Time.now >= log.create_time
      
      assert_equal Birling::Formatter, log.formatter
      assert_equal Time, log.time_source
      assert_equal nil, log.period
    end
  end
  
  def test_with_handle
    s = StringIO.new
    
    log = Birling::Logger.new(s)
    
    assert log.opened?
    
    assert_equal 0, log.size
  end
  
  def test_formatter
    formatter_called = false
    formatter = lambda do |severity, time, program, message|
      formatter_called = true
      message
    end
    
    output = StringIO.new
    log = Birling::Logger.new(output, :formatter => formatter)
    
    log.debug("Test")
    
    assert_equal true, formatter_called
    
    output.rewind
    assert_equal "Test", output.read
  end

  def test_debug_level
    temp_path do |path|
      log = Birling::Logger.new(path)
    
      assert log

      assert log.opened?
      assert !log.closed?
      assert_equal 0, log.size
      
      assert log.debug?

      log.debug("Test")
      
      current_size = log.size
      assert current_size > 0
    end
  end

  def test_reopen
    temp_path do |path|
      log = Birling::Logger.new(path)

      assert log.debug?

      log.debug("Test")
      
      current_size = log.size
      assert current_size > 0
      
      create_time = log.create_time
      assert create_time <= Time.now
      
      log.close
      
      log = Birling::Logger.new(path)
      
      assert_equal current_size, log.size
      assert_equal create_time, log.create_time
    end
  end
  
  def test_cycling
    temp_path(:cycle) do |path|
      start = Time.now
      logger = Birling::Logger.new(path, :period => 1)
      
      assert_equal 1, logger.period
      
      current_path = logger.current_path
      assert_equal '%s', logger.path_time_format
      
      assert_equal 1, (logger.rotation_time - start).to_i
      
      while (logger.current_path == current_path)
        logger.debug("Test")
        
        elapsed = Time.now - start
        
        assert elapsed < 3
      end
      
    ensure
    end
  end
end
