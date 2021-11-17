class CronParser

  attr_accessor :minute, :hour, :day_of_month, :month, :day_of_week, :command
  attr_accessor :source, :error

  def initialize arg
    @source = arg[0]

    # Hardcoding
    @minute = "0 20 40"
    @hour = "1 2 3"
    @day_of_month = "10 11"
    @month = "1 2 3 4 5 6 7 8 9 10 11 12"
    @day_of_week = "1 2 3 4 5 6 7"
    @command = "echo hello"

    # Validate
    begin
    validate_source
    rescue => e
      @error = "An error of type #{e.class} happened, message is: '#{e.message.capitalize}'"
    end
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
      initial: #{source}
      """
    else 
      @error 
    end
  end

  private 

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