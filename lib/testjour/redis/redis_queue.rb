require "redis"

module Testjour

  class RedisQueue

    def initialize(redis_host, queue_namespace)
      @redis = Redis.new(:db => 11, :host => redis_host)
      @queue_namespace = queue_namespace
    end

    attr_reader :redis

    def push(data)
      redis.lpush(key, Marshal.dump(data))
    end

    def pop
      marshalled_result(redis.rpop(key))
    end

    def blocking_pop(timeout)
      popped = redis.brpop(key, timeout)
      marshalled_result(popped.last)
    end

    def reset
      redis.del key
    end

    def all
      redis.lrange(key, 0, -1)
    end

 protected

    def key
      "testjour:#{queue_namespace}:#{queue_name}"
    end

    def queue_name
      raise "Queue name should be defined by a subclass"
    end

    def queue_namespace
      @queue_namespace
    end

    def marshalled_result(result)
      result ? Marshal.load(result) : nil
    end
  end

end