module Testjour

  class FailedFeaturesFormatter

    def initialize(configuration)
      @set  = FailedFeaturesSet.new(configuration.queue_host, configuration.queue_prefix)
      @file_names = []
      @file_colon_lines = Hash.new{|h,k| h[k] = []}
    end

    def after_feature_element(feature_element)
      if feature_element.failed?
        file, line = *feature_element.file_colon_line.split(':')
        @set.add(file)
      end
    end

    def step_name(keyword, step_match, status, source_indent, background)
      @rerun = true if [:failed].index(status)
    end
  end
  
end