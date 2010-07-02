require "testjour/progressbar"
require "testjour/colorer"
require "testjour/result_set"

module Testjour
  class ProgressAndStatsFormatter

    def initialize(step_counter, options = {})
      @options = options
      @progress_bar = ProgressBar.new("0 failures", step_counter.count, options[:simple_progress])
      @result_set   = ResultSet.new
      @failed_scenarios = []
    end

    def result(result)
      @result_set.record(result)
      log_result(result)
      update_progress_bar
      if result.failed?
        @failed_scenarios << "#{result.scenario} (#{result.server_id})"
      end
    end

    def update_progress_bar
      @progress_bar.colorer = colorer
      @progress_bar.title   = title
      @progress_bar.inc
    end

    def log_result(result)
      case result.char
      when "F"
        erase_current_line
        print Testjour::Colorer.failed("F#{@result_set.errors.size}) ")
        puts Testjour::Colorer.failed(result.message)
        puts result.backtrace
        puts
      when "U"
        erase_current_line
        print Testjour::Colorer.undefined("U#{@result_set.undefineds.size}) ")
        puts Testjour::Colorer.undefined(result.backtrace_line)
        puts
      end
    end

    def colorer
      if failed?
        Testjour::Colorer.method(:failed).to_proc
      else
        Testjour::Colorer.method(:passed).to_proc
      end
    end

    def title
      "#{@result_set.slaves} slaves, #{@result_set.errors.size} failures"
    end

    def erase_current_line
      print "\e[K"
    end

    def print_summary
      print_summary_line(:passed)
      puts Colorer.failed("#{@result_set.errors.size} steps failed") unless @result_set.errors.empty?
      print_summary_line(:skipped)
      print_skipped_lines
      print_summary_line(:pending)
      print_summary_line(:undefined)
    end

    def print_skipped_lines
      @result_set.collect { |result| result.status == :skipped }.each do |result|
        puts result.scenario
      end
    end

    def print_stats
      @result_set.each_server_stat do |server_id, steps, total_time, steps_per_second|
        puts "#{server_id} ran #{steps} steps in %.2fs (%.2f steps/s)" % [total_time, steps_per_second]
      end
    end

    def print_failed_scenarios
      return if @failed_scenarios.empty?
      puts Testjour::Colorer.failed("Failed Scenarios:")
      @failed_scenarios.each do |scenario|
        puts Testjour::Colorer.failed(scenario)
      end
    end

    def print_summary_line(step_type)
      count = @result_set.count(step_type)
      return if count.zero?
      puts Colorer.send(step_type, "#{count} steps #{step_type}")
    end
    
    def finish
      @progress_bar.finish
      puts
      puts
      print_failed_scenarios
      puts
      print_summary
      puts
      print_stats
      puts
    end

    def failed?
      if @options[:strict]
        @result_set.errors.any? || @result_set.undefineds.any?
      else
        @result_set.errors.any?
      end
    end

  end
end