module Testjour
  class PlainTextFeatureCollection
    attr_reader :features

    def initialize(configuration, files)
      @configuration = configuration
      @files = files
    end

    def self.load_plain_text_features(configuration, files)
      collection = new(configuration, files)
      collection.load_plain_text_features!
      collection.features
    end

    def load_plain_text_features!
      @features = Cucumber::Ast::Features.new

      Array(@files).each do |f|
        feature_file = Cucumber::FeatureFile.new(f)
        feature = feature_file.parse(step_mother, configuration.cucumber_configuration.options)
        if feature
          features.add_feature(feature)
        end
      end
    end

  protected

    def configuration
      @configuration
    end

    def step_mother
      @configuration.step_mother
    end
  end
end