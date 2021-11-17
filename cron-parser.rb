class CronParser

  attr_accessor :minute, :hour, :day_of_month, :month, :day_of_week, :command
  attr_accessor :source, :error

  def initialize arg
    @source = arg[0]

    # Validate
    begin
    validate_source
    rescue => e
      @error = "An error of type #{e.class} happened, message is: '#{e.message.capitalize}'"
    end

    # Parse
    parse
  end

  def to_s 
    unless @error 
      """
      minute: #{minute}
      hour: #{hour}
      day of month: #{day_of_month}
      month: #{month}
      day of week: #{day_of_week}
      command: #{command}
      """
    else 
      @error 
    end
  end

  private 
    def parse 
      source_parts = source.split

      # ┌───────────── minute (0 - 59)
      # │ ┌───────────── hour (0 - 23)
      # │ │ ┌───────────── day of the month (1 - 31)
      # │ │ │ ┌───────────── month (1 - 12)
      # │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
      # │ │ │ │ │                                   7 is also Sunday on some systems)
      # │ │ │ │ │
      # │ │ │ │ │
      # * * * * * <command to execute>
      self.minute = source_parts[0]
      self.hour = source_parts[1]
      self.day_of_month = source_parts[2]
      self.month = source_parts[3]
      self.day_of_week = source_parts[4]
      self.command = source_parts[5..-1].join(' ')
    end 

    def validate_source
      is_str?
      able_to_split?
      correct_length?
    end

    def is_str?
      unless @source.respond_to?(:to_str)
        raise ArgumentError, 'not a valid cronline string'
      end
    end

    def able_to_split?
      unless @source.respond_to?(:split)
        raise ArgumentError, 'not a valid cronline'
      end
    end

    def correct_length?
      source_length = @source.split(/\s+/).length
      # Command may have spaces inside, so maybe greater than 6 when split
      unless source_length >= 5
        raise ArgumentError, 'not a valid cronline length'
      end
    end

end

puts CronParser.new(ARGV)