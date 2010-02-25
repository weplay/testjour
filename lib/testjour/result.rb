require "English"
require "socket"

module Testjour

  class Result
    attr_reader :time
    attr_reader :status
    attr_reader :message
    attr_reader :backtrace
    attr_reader :backtrace_line
    attr_reader :scenario

    CHARS = {
      :undefined => 'U',
      :passed    => '.',
      :failed    => 'F',
      :pending   => 'P',
      :skipped   => 'S'
    }

    def initialize(time, scenario_file_colon_line, status, step_match = nil, exception = nil)
      @time   = time
      @status = status
      @scenario_file_colon_line = scenario_file_colon_line
      
      if step_match
        @backtrace_line = step_match.backtrace_line
      end

      if exception
        @message    = exception.message.to_s
        @backtrace  = exception.backtrace.join("\n")
      end

      @pid        = Testjour.effective_pid
      @hostname   = Testjour.socket_hostname
    end

    def server_id
      "#{@hostname} [#{@pid}]"
    end

    def scenario
      @scenario_file_colon_line
    end

    def char
      CHARS[@status]
    end

    def failed?
      status == :failed
    end

    def undefined?
      status == :undefined
    end

  end

end