require "testjour/core_extensions/wait_for_service"
require "testjour/redis/redis_queue"

module Testjour

  class ResultsQueue < RedisQueue

    def initialize(redis_host, queue_namespace, queue_timeout)
      super(redis_host, queue_namespace)
      @queue_timeout = queue_timeout
    end

    def pop
      SystemTimer.timeout_after(@queue_timeout) do
        result = nil

        while result.nil?
          result = super
          sleep 0.1 unless result
        end

        result
      end
    end

  protected

    def queue_name
      "results"
    end

  end

end