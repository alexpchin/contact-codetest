require_relative 'spec-helper'
require_relative '../lib/cron-parser'

describe CronParser do
  describe "output of example" do
    it "returns what Contact requested" do
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
  end
end