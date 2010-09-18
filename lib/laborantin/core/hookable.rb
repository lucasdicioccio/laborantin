
module Laborantin
  module Metaprog
    module Hookable
      # A hash to store setup/teardown hooks.
      attr_accessor :hooks

      # Registers setup hooks.
      def setup(*args)
        hooks[:setup] = [*args].flatten
      end

      # Register teardown hooks.
      def teardown(*args)
        hooks[:teardown] = [*args].flatten
      end
    end
  end
end
      
