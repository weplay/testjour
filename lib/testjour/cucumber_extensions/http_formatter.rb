require 'socket'
require 'English'
require 'cucumber/formatter/console'
require 'testjour/result'

module Testjour

  class HttpFormatter

    def initialize(configuration)
      @configuration = configuration
    end

    def before_multiline_arg(multiline_arg)
      @multiline_arg = true
    end

    def after_multiline_arg(multiline_arg)
      @multiline_arg = false
    end

    def before_step(step)
      @step_start = Time.now
    end

    def before_background(background)
      @scenario_file_colon_line = background.backtrace_line
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
      @scenario_file_colon_line = file_colon_line
    end

    def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
      progress(Time.now - @step_start, status, @scenario_file_colon_line, step_match, exception)
    end

    def before_outline_table(outline_table)
      @outline_table = outline_table
    end

    def after_outline_table(outline_table)
      @outline_table = nil
    end

    def table_cell_value(value, status)
      return unless @outline_table
      progress(0.0, status) unless table_header_cell?(status)
    end

  private

    def progress(time, status, scenario_file_colon_line = nil, step_match = nil, exception = nil)
      queue = ResultsQueue.new(@configuration.queue_host, @configuration.queue_prefix,  @configuration.queue_timeout)
      queue.push(Result.new(time, scenario_file_colon_line, status, step_match, exception))
    end

    def table_header_cell?(status)
      status == :skipped_param
    end

  end

end