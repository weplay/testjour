require "testjour/commands/command"
require "cucumber"
require "testjour/cucumber_extensions/http_formatter"

module Testjour
module Commands
    
  class LocalRun < Command
    
    def execute
      File.open("testjour.log", "w") do |log|
        log.puts @args.first
      end
      
      require 'cucumber/cli/main'
      
      configuration.load_language
      step_mother.options = configuration.options

      require_files
      
      HttpQueue.with_net_http do |http|
        code = 200
        
        while code == 200
          get = Net::HTTP::Get.new("/feature_files")
          response  = http.request(get)
          code      = response.code.to_i
          
          if code == 200
            feature_file = response.body
            features = load_plain_text_features(feature_file)
            visit_features(features)
          end
        end
      end
    end
    
    def visit_features(features)
      visitor = Testjour::HttpFormatter.new(step_mother, StringIO.new, configuration.options)
      visitor.visit_features(features)
    end
    
    def configuration
      return @configuration if @configuration
      
      @configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      @configuration.parse!(@args)
      @configuration
    end
    
    def require_files
      configuration.files_to_require.each do |lib|
        require lib
      end
    end
    
    def load_plain_text_features(files)
      features = Cucumber::Ast::Features.new(configuration.ast_filter)
      parser = Cucumber::Parser::FeatureParser.new

      files.each do |f|
        features.add_feature(parser.parse_file(f))
      end
      
      return features
    end
    
    def step_mother
      Cucumber::Cli::Main.instance_variable_get("@step_mother")
    end
    
  end
  
end
end