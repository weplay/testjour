module Testjour
  class PlainTextFeatureCollection
    attr_reader :features

    def initialize(configuration, files)
      @configuration = configuration
      @files = files
      @features_map = {}
    end

    def load_plain_text_features!
      @features = Cucumber::Ast::Features.new

      Array(@files).each do |f|
        feature_file = Cucumber::FeatureFile.new(f)
        feature = feature_file.parse(step_mother, configuration.cucumber_configuration.options)
        if feature
          features.add_feature(feature)
          self[f] = feature
        end
      end
    end

    def []=(file, feature)
      @features_map[file] = feature
    end

    def [](file)
      @features_map[file]
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