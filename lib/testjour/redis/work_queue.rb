require "testjour/redis/redis_queue"

module Testjour

  class WorkQueue < RedisQueue
    
  protected
  
    def queue_name
      "work"
    end
    
  end
  
end