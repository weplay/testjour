require "uri"
require "systemu"
require "testjour/core_extensions/retryable"

module Testjour
  
  class RsyncFailed < StandardError
  end
  
  class Rsync
    
    def self.copy_to_current_directory_from(source_uri)
      new(source_uri, File.expand_path(".")).copy_with_retry
    end
    
    def self.copy_from_current_directory_to(destination_uri, opts = {})
      new(File.expand_path("."), destination_uri, opts).copy_with_retry
    end
    
    def initialize(source_uri, destination_uri, opts = {})
      @source_uri = source_uri
      @destination_uri = destination_uri
      @options = opts
    end

    def copy_with_retry
      retryable :tries => 2, :on => RsyncFailed do
        Testjour.logger.info "Rsyncing: #{command}"
        copy
        
        if successful?
          Testjour.logger.debug("Rsync finished in %.2fs" % elapsed_time)
        else
          Testjour.logger.debug("Rsync failed in %.2fs" % elapsed_time)
          Testjour.logger.debug("Rsync stdout: #{@stdout}")
          Testjour.logger.debug("Rsync stderr: #{@stderr}")
          raise RsyncFailed.new 
        end
      end
    end
    
    def copy
      @start_time = Time.now
      
      status, @stdout, @stderr = systemu(command)
      @exit_code = status.exitstatus
    end
    
    def elapsed_time
      Time.now - @start_time
    end
    
    def successful?
      @exit_code.zero?
    end
    
    def command
      exclude_args = excludes.map { |exclude| "--exclude=#{exclude}" }.join(" ")
      "rsync -az -e \"ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no\" --delete #{exclude_args} #{@source_uri}/ #{@destination_uri}"
    end
    
    def excludes
      excludes = [".git", "*.log", "*.pid"]
      if @options[:excludes]
        excludes += @options[:excludes]
        excludes.uniq!
      end
      excludes
    end
  end
end