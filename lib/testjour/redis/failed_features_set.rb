require "redis"

module Testjour

  class FailedFeaturesSet
    
    def initialize(redis_host, queue_name)
      @redis = Redis.new(:db => 11, :host => redis_host)
      @queue_name = queue_name
    end
    
    attr_reader :redis

    def add(data)
      redis.sadd(key, data)
    end
    
    def all
      redis.smembers(key)
    end

    def reset
      redis.del key
    end
    
 protected
    
    def key
      "testjour:#{@queue_name}_failed"
    end

  end

end