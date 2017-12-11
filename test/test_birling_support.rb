require File.expand_path('helper', File.dirname(__FILE__))

class TestBirlingSupport < Test::Unit::TestCase
  def test_next_day_on_dst_flip
    in_time_zone('UTC') do
      time = Time.new(2012, 11, 4)
      
      assert_equal time.day, (time + 86400).day
      
      next_day = Birling::Support.next_day(time)
      
      assert_equal 2012, next_day.year
      assert_equal 11, next_day.month
      assert_equal 5, next_day.day
      assert_equal 0, next_day.hour
      assert_equal 0, next_day.min
      assert_equal 0, next_day.sec
    end
  end

  def test_hour_day_on_dst_flip
    in_time_zone('UTC') do
      time = Time.new(2012, 11, 4, 0, 59, 59) + 1
      
      assert_equal time.hour, (time + 3600).hour
      
      next_hour = Birling::Support.next_hour(time)
      
      assert_equal 2012, next_hour.year
      assert_equal 11, next_hour.month
      assert_equal 4, next_hour.day
      assert_equal 1, next_hour.hour
      assert_equal 0, next_hour.min
      assert_equal 0, next_hour.sec
      
      assert_equal 3600, next_hour - time
    end
  end

  def test_next_day_at_year_end
    in_time_zone('UTC') do
      time = Time.new(2012, 12, 31)
      
      next_day = Birling::Support.next_day(time)
      
      assert_equal 2013, next_day.year
      assert_equal 1, next_day.month
      assert_equal 1, next_day.day
      assert_equal 0, next_day.hour
      assert_equal 0, next_day.min
      assert_equal 0, next_day.sec
    end
  end
end
