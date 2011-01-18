require "testjour/result_set"

module Testjour
  class RerunFormatter

    def initialize(step_counter, options = {})
      @options = options
      @failed_scenarios = []
    end

    def result(result)
      if result.failed?
        @failed_scenarios << result.scenario

        if result.scenario.nil?
          Testjour.logger.debug("FAILED RESULT WITH nil SCENARIO")
          Testjour.logger.debug("result.status: #{result.status}")
          Testjour.logger.debug("result.server_id: #{result.server_id}")
          Testjour.logger.debug("result.message: #{result.message}")
        end
      end
    end

    def finish
      print_rerun_file
    end

  protected

    def print_rerun_file
      failed_features = @failed_scenarios.inject({}) do |hash, val|
        hash[val.split(":").first] = true
        hash
      end.keys
      File.open("rerun.txt", "w") do |f|
        f.write(failed_features.join(" "))
      end
    end

  end

end
