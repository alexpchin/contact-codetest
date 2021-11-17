class CronParser

  def initialize arg 
    @source = arg[0]
  end

  def to_s 
    """
    minute: 0 20 40
    hour: 1 2 3
    day of month: 10 11
    month: 1 2 3 4 5 6 7 8 9 10 11 12
    day of week: 1 2 3 4 5 6 7
    command: echo hello
    initial: #{@source}
    """
  end

end

puts CronParser.new(ARGV)