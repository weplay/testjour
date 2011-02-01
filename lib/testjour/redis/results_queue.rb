require "testjour/core_extensions/wait_for_service"
require "testjour/redis/redis_queue"

module Testjour

  class ResultsQueue < RedisQueue

    def initialize(redis_host, queue_namespace, queue_timeout)
      super(redis_host, queue_namespace)
      @queue_timeout = queue_timeout
    end

    def pop
      blocking_pop(@queue_timeout)
    end

  protected

    def queue_name
      "results"
    end

  end

end