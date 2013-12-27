require 'terminal-table'

# Encapsulates the formatting and output of Memtf analysis.
#
# Example Report:
#
#   +-----------------------------+--------+---------+---------+---------+---------+
#   | Class                       | Impact | Leakage | Change  | Objects | Change  |
#   +-----------------------------+--------+---------+---------+---------+---------+
#   | Array                       | 96.85% | 4.972MB | 4.972MB | 2189    | 1985    |
#   ...
#
class Memtf::Reporter
  # The report table headers
  HEADERS = ['Class', 'Impact', 'Leakage', 'Change', 'Objects', 'Change']

  attr_reader :group, :options

  # Print the analysis in a concise tabular format.
  #
  # @param [String] group
  def self.report(group)
    new(group).report
  end

  def initialize(group, options={})
    @group   = group
    @options = options
  end

  # Print the analysis in a concise tabular format.
  #
  # @return [Terminal::Table]
  def report
    Terminal::Table.new(:headings => HEADERS) do |t|
      group_analysis = Memtf::Analyzer.analyze_group(group)
      group_analysis.sort_by { |k,v| -v['impact'] }.each do |k,v|
        t << [k,
              to_pct(v['impact']),
              to_MB(v['size']),
              to_MB(v['size_delta']),
              v['count'],
              v['count_delta']]
      end
    end
  end

  private

  # @param [Number] bytes
  def to_MB(bytes)
    "%.3fMB" % [bytes]
  end

  # @param [Number] num
  def to_pct(num)
    "%.2f%" % [num * 100]
  end
end
