require File.expand_path('helper', File.dirname(__FILE__))

class TestBirling < Test::Unit::TestCase
  def test_module
    assert Birling
  end
  
  def test_open
    _path = nil
    
    temp_path do |path|
      _path = path
      log = Birling.open(path)
      
      assert_equal Birling::Logger, log.class
      
      assert log
      assert File.exist?(path)

      assert log.opened?
      assert !log.closed?
      assert_equal 0, log.size
      
      assert log.debug?
      
      log.debug("Test")
      
      assert log.size > 0
      
      log.close
      
      assert !log.opened?
      assert log.closed?
    end
    
    assert !File.exist?(_path)
  end
end
