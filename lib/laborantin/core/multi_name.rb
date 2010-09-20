
module Laborantin
  module Metaprog
    module MultiName
      AVAILABLE_NAMES = [:cli, :fs]

      def set_name(sym, val)
        raise ArgumentError, "invalid name sym: #{sym}, expected in #{AVAILABLE_NAMES.inspect}" unless AVAILABLE_NAMES.include?(sym)
        send "#{sym}_name=", val
      end

      # a way to name on the command line
      attr_writer :cli_name
      def cli_name
        @cli_name || name.duck_case
      end

      # a way to name on the filesystem
      attr_writer :fs_name
      def fs_name
        @fs_name || name.duck_case
      end
    end
  end
end
