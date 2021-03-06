
module Laborantin
  module Metaprog
    module Configurable
      # A hash placeholder for extra config (e.g. git revision for the git implementation)
      attr_accessor :config

      # saves the @config in a YAML config file
      def save_config
        File.open(config_path, 'w') do |f|
          f.puts YAML.dump(config)
        end
      end

      # restore the configuration from the config file
      def load_config!(path=config_path)
        if File.file?(path)
          @config = YAML.load_file(path)
        end
        @config ||= {}
      end

      def config_path
        "config.yaml"
      end
    end
  end
end
