class CronParser

  RANGE_IDENTIFIER = '-'
  STEP_IDENTIFIER = '/'
  WILDCARD_IDENTIFIER = '*'
  COMBINATION_IDENTIFIER = ','
  MIN_SOURCE_LENGTH = 5

  TIMES = {
    minute: (0...60).map.to_a,
    hour: (0...24).map.to_a,
    day_of_month: (1..31).map.to_a,
    month: (1..12).map.to_a,
    day_of_week: (1..7).map.to_a, # Example uses 1 - 7 
  }

  MONTHS = {
    "jan" => "1",
    "feb" => "2",
    "mar" => "3",
    "apr" => "4",
    "may" => "5",
    "jun" => "6",
    "jul" => "7",
    "aug" => "8",
    "sep" => "9",
    "oct" => "10",
    "nov" => "11",
    "dec" => "12",
    "sun" => "0",
  }

  DAYS = {
    "mon" => "1",
    "tue" => "2",
    "wed" => "3",
    "thu" => "4",
    "fri" => "5",
    "sat" => "6"
 }

  attr_accessor :minute, :hour, :day_of_month, :month, :day_of_week, :command
  attr_accessor :source, :error

  def initialize arg = []
    begin
      raise ArgumentError, 'no argument provided' if !arg[0]
      @source = handle_non_standard(arg[0])
      translate_words
      pre_validate
      parse
      post_validate
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
"""
    else 
      @error 
    end
  end

  private

    # Handle non-standard scheduling definitions
    def handle_non_standard source
      unless source.scan(/@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly/).length > 1
        case source[/@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly/]
        when '@reboot'
          raise ArgumentError, "can't output @reboot"
        when '@yearly', '@annually'
          "0 0 1 1 * #{source.partition(' ').last}"
        when '@monthly'
          "0 0 1 * * #{source.partition(' ').last}"
        when '@weekly'
          "0 0 * * 0 #{source.partition(' ').last}"
        when '@daily', '@midnight'
          "0 0 * * * #{source.partition(' ').last}"
        when '@hourly'
          "0 * * * * #{source.partition(' ').last}"
        else
          source
        end
      else 
        raise ArgumentError, 'too many non-standard defintions included'
      end
    end

    # Handle words in cronline and convert to numbers
    def translate_words
      [DAYS, MONTHS].each { |hash| translate(hash) }
    end

    # NOTE: Don't replace if day or month value is included in command
    def translate dictionary
      word_in_wrong_place?

      temp_source = source.clone
      temp_arr = temp_source.split(' ')
      everything_but_command = temp_arr[0..4]&.join(' ')
      command = temp_source.gsub!(everything_but_command, '')
      dictionary.each do |k, v|
        everything_but_command.gsub!(k, v)
      end
      self.source = "#{everything_but_command} #{command}"
    end

    # Validate if words have been used in the wrong place
    def word_in_wrong_place?
      temp_arr = source.split(' ')[0..5] 
      
      MONTHS.keys.each do |month|
        temp_arr.each_with_index do |item, index|
          if item.include?(month) && index != 3
            raise ArgumentError, 'incorrect position for month string'
          end 
        end 
      end

      DAYS.keys.each do |day|
        temp_arr.each_with_index do |item, index|
          if item.include?(day) && index != 4
            raise ArgumentError, 'incorrect position for day string'
          end
        end
      end
    end

    # ┌───────────── minute (0 - 59)
    # │ ┌───────────── hour (0 - 23)
    # │ │ ┌───────────── day of the month (1 - 31)
    # │ │ │ ┌───────────── month (1 - 12)
    # │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
    # │ │ │ │ │                                   7 is also Sunday on some systems)
    # │ │ │ │ │
    # │ │ │ │ │
    # * * * * * <command to execute>
    def parse
      source_parts = source.split
      self.minute = parse_part(source_parts[0], :minute)
      self.hour = parse_part(source_parts[1], :hour)
      self.day_of_month = parse_part(source_parts[2], :day_of_month)
      self.month = parse_part(source_parts[3], :month)
      self.day_of_week = parse_part(source_parts[4], :day_of_week)
      self.command = source_parts[5..-1]&.join(' ')
    end

    def parse_part part, time_denomination
      return print_combination(part, time_denomination) if is_combination?(part)
      return print_range(part, time_denomination) if is_range?(part)
      return print_step(part, time_denomination) if is_step?(part)
      return print_single(part, time_denomination) if is_single_value?(part)
      return print_wildcard(time_denomination) if is_wildcard?(part) 
    end

    def print_wildcard time_denomination
      TIMES.fetch(time_denomination)&.join(' ')
    end 

    def print_range part, time_denomination
      range = part.split(RANGE_IDENTIFIER)
      start = range[0].to_i
      finish = range[1].to_i
      TIMES.fetch(time_denomination)[start..finish]&.join(' ')
    end

    def print_step part, time_denomination
      step = part.partition(STEP_IDENTIFIER).last.to_i
      TIMES.fetch(time_denomination).each_slice(step).map(&:first)&.join(' ')
    end 

    def print_single part, time_denomination
      unless TIMES.fetch(time_denomination).include? part.to_i
        raise ArgumentError, 'incorrect value for time denomination'
      else  
        part
      end 
    end

    def print_combination part, time_denomination
      combinations = part.split(COMBINATION_IDENTIFIER)
      combinations.map do |combination|
        parse_part(combination, time_denomination)
      end.sort.join(' ')
    end 

    # - a wildcard `*` which equates to all valid values.
    def is_wildcard? part 
      part == WILDCARD_IDENTIFIER      
    end 

    # - a range `1-10` which equates to all valid values between start-end inclusive.
    def is_range? part 
      part.include? RANGE_IDENTIFIER
    end 

    # - a step `*/2` which equates to every second value starting at 0, or 1 for day of month and month.
    def is_step? part 
      part.include? STEP_IDENTIFIER
    end 

    # - a single value 2 which would be 2.
    def is_single_value? part
      part.to_i.to_s == part
    end 

    # - a combination of the above separated by a `,`
    def is_combination? part
      part.include? COMBINATION_IDENTIFIER
    end

    # Run all validation functions
    def pre_validate
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

    # Command may have spaces inside, so maybe greater than 6 when split
    def correct_length?
      source_length = @source.split(/\s+/).length
      unless source_length >= MIN_SOURCE_LENGTH
        raise ArgumentError, 'not a valid cronline length'
      end
    end

    def post_validate
      [minute, hour, day_of_month, month, day_of_week, command].each do |output|
        if !output || output.nil? || output.empty?
          raise ArgumentError, 'something went wrong'
        end
      end
    end

end