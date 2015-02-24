# birling

A replacement for Logger that offers more robust handling of log rotation.

The built-in logger supports log rotation on a daily, weekly or monthly basis,
but not with more fine-grained control. Birling will allow rotation by hour,
by day, or by an arbitrary amount of time expressed in seconds.

Additionally, Birling will automatically remove old log files. These can be
pruned off by age, by retaining a minimum number of them, or a combination of
both.

## Example

The interface is very similar to the [built in logger](http://rubygems.org/gems/logger)
facility that ships with Ruby:

```ruby
logger = Birling::Logger.new('test.log')

logger.info("Application starting up.")
logger.debug("application_init()")
```

A short-hand method is available:

```ruby
logger = Birling.open('test.log')
```

Log rotation parameters are quite flexible. For example, to retain a maximum
of ten hourly logs:

```ruby
logger = Birling.open(
  'test.log',
  period: :hourly,
  retain_count: 10
)
```

Alternatively the retention period can be expressed in terms of time where
log files that could have been created by this logger which are older than
that period will be removed:

```ruby
logger = Birling.open(
  'test.log',
  period: :hourly,
  retain_period: 10 * 3600
)
```

The format of the resulting log-file can be adjusted by supplying a formatter.
Several arguments passed to the formatter's `call` method, so a `lambda`, a
`module` or an object instance could be used for this purpose.

Example:

```ruby
logger = Birling.open(
  'test.log',
  formatter: lambda { |severity, time, program, message| "#{time}> #{message}\n" }
)
```

Note that the formatter is responsible for introducing any line-feeds into
the resulting output stream. This gives the formatter complete control over
what is written to the log.

## Limitations

The log rotation feature, for reasons that should be obvious, will not work
on loggers that are created with an existing file-handle. For example, when
using `STDOUT` the logger will not rotate.

## Copyright

Copyright (c) 2011-2015 Scott Tadman, The Working Group Inc.
