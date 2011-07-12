require 'laborantin/core/resolutions'

module Laborantin
  module Metaprog
    module Verifications
      module InstanceMethods
        attr_accessor :verifications

        def verifications
          @verifications ||= []
        end

        def verify(name, &blk)
          dep = Verification.new(name)
          dep.instance_eval &blk
          verifications << dep
          dep
        end

        def valid?(*ary)
          verifications.inject(true){|b,verif| b && verif.correct?(*ary)}
        end
      end

      include InstanceMethods

      class Verification
        include Metaprog::Describable
        include Metaprog::Resolutions
        attr_reader :name, :block
        def initialize(name)
          @name = name
        end

        def check(&blk)
          @block = blk
        end

        def correct?(*ary)
          raise RuntimeError, "no block for verification #{self}" unless block
          block.call(*ary) && valid?(*ary)
        end

        include InstanceMethods
      end
    end
  end
end
