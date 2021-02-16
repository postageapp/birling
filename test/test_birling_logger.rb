require File.expand_path('helper', __dir__)
require 'stringio'

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

  def test_io_compatible
    stdout = $stdout

    buffer = StringIO.new

    log = Birling::Logger.new(buffer, time_source: Time::Warped)

    assert log.opened?

    assert_equal 0, log.size

    $stdout = log

    start = Time.parse('2017-10-10 12:00:00')

    Time::Warped.now = start

    puts "Test"

    log.close

    expected = "[2017-10-10 12:00:00] Test\n"

    assert_equal expected, buffer.string.to_s

  ensure
    $stdout = stdout
  end

  def test_formatter
    formatter_called = false
    formatter = lambda do |severity, time, program, message|
      formatter_called = true
      message
    end

    output = StringIO.new
    log = Birling::Logger.new(output, formatter: formatter)

    log.debug("Test")

    assert_equal true, formatter_called

    output.rewind
    assert_equal "Test", output.read
  end

  def test_default_level
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

  def test_direct_write
    output = StringIO.new

    log = Birling::Logger.new(output)

    log << "TEST"

    assert_equal "TEST", output.string
  end

  def test_level_filter
    output = StringIO.new

    log = Birling::Logger.new(
      output,
      formatter: lambda { |s, t, p, m| "#{m}\n" },
      severity: :info
    )

    log.debug("DEBUG")
    log.info("INFO")

    output.rewind
    assert_equal "INFO\n", output.read
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

  def test_time_source
    temp_path do |path|
      frozen_time = Time.now
      Time::Warped.now = frozen_time

      logger = Birling::Logger.new(path, time_source: Time::Warped)

      assert_equal frozen_time, logger.time_source.now
    end
  end

  def test_cycling
    temp_path(:cycle) do |path|
      start = Time.now
      Time::Warped.now = start
      logger = Birling::Logger.new(path, period: 1, time_source: Time::Warped)

      assert_equal 1, logger.period

      current_path = logger.current_path
      assert_equal '%s', logger.path_time_format

      logger.debug("Test")

      Time::Warped.now += 1

      logger.debug("Test")

      assert_not_equal current_path, logger.current_path

      current_path = logger.current_path

      Time::Warped.now += 1

      logger.debug("Test")

      assert_not_equal current_path, logger.current_path
    end
  end

  def test_retain_count
    temp_path(:cycle) do |path|
      start = Time.now
      Time::Warped.now = start

      retain_count = 10

      logger = Birling::Logger.new(
        path,
        period: 1,
        time_source: Time::Warped,
        retain_count: retain_count
      )

      (retain_count + 5).times do |n|
        logger.debug("Test")

        Time::Warped.now += 1

        logger.debug("Test")
      end

      assert_equal retain_count, Dir.glob(logger.path_format % '*').length
    end
  end

  def test_default_formatter
    temp_path(:cycle) do |path|
      logger = Birling::Logger.new(path)

      lines = 100

      lines.times do
        logger.debug("Test")
      end

      logger.close

      assert_equal lines, File.readlines(path).length
    end
  end

  def test_retain_period
    temp_path(:cycle) do |path|
      retain_period = 3

      logger = Birling::Logger.new(
        path,
        period: 1,
        retain_period: retain_period
      )

      assert_equal true, File.exist?(path)
      assert_equal true, File.symlink?(path)

      finish = Time.now + retain_period + 5

      while (Time.now < finish)
        logger.debug("Test")
        Time::Warped.now += 1
        logger.debug("Test")
      end

      assert_equal retain_period + 1, Dir.glob(logger.path_format % '*').length
    end
  end

  def test_irregular_utf8_data
    temp_path(:cycle) do |path|
      logger = Birling::Logger.new(path, encoding: 'BINARY')

      invalid = (0..255).to_a.pack('C*')

      logger.debug(invalid)
    end
  end
end
