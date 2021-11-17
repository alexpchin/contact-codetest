require_relative 'spec-helper'
require_relative '../lib/cron-parser'

describe CronParser do
  describe "returns what Contact requested" do
    it "returns every 20 minutes (*/20) on the first 3 hours of the day (1-3) on the 10th and 11th of each month" do
      parser = CronParser.new(['*/20 1-3 10,11 * * echo hello'])
      expect(parser.to_s).to eq (
"""
minute: 0 20 40
hour: 1 2 3
day of month: 10 11
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 1 2 3 4 5 6 7
command: echo hello
""")
    end

    it "returns 9am every day" do
      parser = CronParser.new(['0 9 * * * echo hello'])
      expect(parser.to_s).to eq (
"""
minute: 0
hour: 9
day of month: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 1 2 3 4 5 6 7
command: echo hello
""")
    end
  end

  # Further tests
  describe "no argument provided" do
    it "returns an error if no argument is provided" do
      parser = CronParser.new()
      expect(parser.to_s).to eq ("An error of type ArgumentError happened, message is: 'No argument provided'")
    end
  end

  describe "every minute" do
    it "returns correct every minute" do
      parser = CronParser.new(['* * * * * echo every minute'])
      expect(parser.to_s).to eq (
"""
minute: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59
hour: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
day of month: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 1 2 3 4 5 6 7
command: echo every minute
""")
    end
  end

  describe "every weekend" do
    it "returns correct every weekend" do
      parser = CronParser.new(['0 0 * * 6,7 echo every weekend'])
      expect(parser.to_s).to eq (
"""
minute: 0
hour: 0
day of month: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 6 7
command: echo every weekend
""")
    end
  end

  describe "every friday at 11pm" do
    it "returns correct every weekend" do
      parser = CronParser.new(['0 23 * * 5 echo every friday at 11pm'])
      expect(parser.to_s).to eq (
"""
minute: 0
hour: 23
day of month: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 5
command: echo every friday at 11pm
""")
    end
  end

  # Harder tests
  describe "common issues" do
    it "returns correctly when a crontab line contains both day of week and day of month, i.e. At every minute on day-of-month 13 and on Friday." do
      parser = CronParser.new(['* * 13 * 5 command'])
      expect(parser.to_s).to eq (
"""
minute: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59
hour: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
day of month: 13
month: 1 2 3 4 5 6 7 8 9 10 11 12
day of week: 5
command: command
""")
    end
  end

  describe "non-standard definitions" do
    it "returns @yearly when using cron syntax" do
      parser = CronParser.new(['0 0 1 1 * echo hello'])
      expect(parser.to_s).to eq (
"""
minute: 0
hour: 0
day of month: 1
month: 1
day of week: 1 2 3 4 5 6 7
command: echo hello
""")
    end

    it "returns @yearly when using @yearly syntax" do
      parser = CronParser.new(['@yearly echo hello'])
      expect(parser.to_s).to eq (
"""
minute: 0
hour: 0
day of month: 1
month: 1
day of week: 1 2 3 4 5 6 7
command: echo hello
""")
    end
    
    it "returns @annually when using @annually syntax" do
      parser = CronParser.new(['@annually echo hello'])
      expect(parser.to_s).to eq (
"""
minute: 0
hour: 0
day of month: 1
month: 1
day of week: 1 2 3 4 5 6 7
command: echo hello
""")
    end

    it "returns an error when using more than one non-standard definition" do
      parser = CronParser.new(['@annually @yearly echo hello'])
      expect(parser.to_s).to eq ("An error of type ArgumentError happened, message is: 'Too many non-standard defintions included'")
    end
  end
end