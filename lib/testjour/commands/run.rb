require "optparse"
require "socket"
require "etc"

require "testjour/commands/command"
require "testjour/redis/results_queue"
require "testjour/redis/work_queue"
require "testjour/configuration"
require "testjour/cucumber_extensions/step_counter"
require "testjour/cucumber_extensions/feature_file_finder"
require "testjour/results_formatters"
require "testjour/result"

module Testjour
module Commands

  class Run < Command

    def execute
      configuration.load_additional_args_from_external_file
      configuration.parse!
      configuration.setup

      if configuration.feature_files.any?
        reset_redis
        remove_rerun
        queue_features

        at_exit do
          Testjour.logger.info caller.join("\n")
          reset_redis
        end


        @started_slaves = 0
        start_slaves

        puts "Requested build from #{@started_slaves} slaves... (Waiting for #{step_counter.count} results)"
        puts

        print_results
      else
        Testjour.logger.info("No feature files. Quitting.")
      end
    end

    def reset_redis
      [results_queue, work_queue].each { |r| r.reset }
    end

    def remove_rerun
      File.unlink("rerun.txt") if File.exists?("rerun.txt")
    end

    def queue_features
      Testjour.logger.info("Queuing features...")
      configuration.feature_files.each do |feature_file|
        work_queue.push(feature_file)
        Testjour.logger.info "Queued: #{feature_file}"
      end
    end

    def start_slaves
      start_local_slaves
      start_remote_slaves
    end

    def start_local_slaves
      configuration.local_slave_count.times do
        @started_slaves += 1
        start_slave
      end
    end

    def start_remote_slaves
      if configuration.remote_slaves.any?
        if configuration.external_rsync_uri
          Rsync.copy_from_current_directory_to(configuration.external_rsync_uri)
        end
        configuration.remote_slaves.each do |remote_slave|
          @started_slaves += start_remote_slave(remote_slave)
        end
      end
    end

    def start_remote_slave(remote_slave)
      num_workers = 1
      if remote_slave.match(/\?workers=(\d+)/)
        num_workers = $1.to_i
        remote_slave.gsub(/\?workers=(\d+)/, '')
      end
      uri = URI.parse(remote_slave)
      cmd = remote_slave_run_command(uri.user, uri.host, uri.path, num_workers)
      Testjour.logger.info "Starting remote slave: #{cmd}"
      detached_exec(cmd)
      num_workers
    end

    def remote_slave_run_command(user, host, path, max_remote_slaves)
      "ssh -o StrictHostKeyChecking=no #{user}#{'@' if user}#{host} testjour run:remote --in=#{path} --max-remote-slaves=#{max_remote_slaves} #{configuration.run_slave_args.join(' ')} #{testjour_uri}".squeeze(" ")
    end

    def start_slave
      Testjour.logger.info "Starting slave: #{local_run_command}"
      detached_exec(local_run_command)
    end

    def print_results
      formatters = [ProgressAndStatsFormatter.new(step_counter, configuration.options)]
      formatters << RerunFormatter.new(step_counter, configuration.options) if configuration.rerun?
      step_counter.count.times do
        result = results_queue.pop
        formatters.each do |formatter|
          formatter.result(result)
        end
      end
      formatters.each do |formatter|
        formatter.finish
      end
      return formatters.first.failed? ? 1 : 0
    end

    def step_counter
      return @step_counter if @step_counter

      features = load_plain_text_features(configuration.feature_files)
      @step_counter = Testjour::StepCounter.new
      tree_walker = Cucumber::Ast::TreeWalker.new(step_mother, [@step_counter])
      tree_walker.options = configuration.cucumber_configuration.options
      tree_walker.visit_features(features)
      return @step_counter
    end

    def local_run_command
      "testjour run:slave #{configuration.run_slave_args.join(' ')} #{testjour_uri}".squeeze(" ")
    end

    def testjour_uri
      if configuration.external_rsync_uri
        "rsync://#{configuration.external_rsync_uri}"
      else
        user = Etc.getpwuid.name
        host = Testjour.socket_hostname
        "rsync://#{user}@#{host}" + File.expand_path(".")
      end
    end

    def testjour_path
      File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
    end

  private

    def work_queue
      @work_queue ||= WorkQueue.new(configuration.queue_host, configuration.queue_prefix)
    end
  
    def results_queue
      @results_queue ||= ResultsQueue.new(configuration.queue_host, configuration.queue_prefix, configuration.queue_timeout)
    end

  end

end
end