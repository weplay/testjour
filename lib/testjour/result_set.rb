module Testjour
  class ResultSet

    attr_reader :errors_count
    attr_reader :undefineds_count

    def initialize
      @counts   = Hash.new { |h, result|    h[result]    = 0 }
      @results  = Hash.new { |h, server_id| h[server_id] = [] }
      @undefineds_count = 0
      @errors_count = 0
    end

    def record(result)
      @errors_count += 1 if result.failed?
      @undefineds_count += 1 if result.undefined?

      @results[result.server_id] << result
      @counts[result.status] += 1
    end

    def count(result)
      @counts[result]
    end

    def each_server_stat(&block)
      @results.sort_by { |server_id, times| server_id }.each do |server_id, results|
        total_time       = total_time(results)
        steps_per_second = results.size.to_f / total_time.to_f

        block.call(server_id, results.size, total_time, steps_per_second)
      end
    end

    def has_errors?
      @errors_count > 0
    end

    def has_undefineds?
      @undefineds_count > 0
    end

    def slaves
      @results.keys.size
    end

  protected

    def total_time(results)
      results.inject(0) { |memo, r| r.time + memo }
    end

  end
end