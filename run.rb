require File.join(File.dirname(__FILE__), 'lib/cron-parser')

puts CronParser.new(ARGV)