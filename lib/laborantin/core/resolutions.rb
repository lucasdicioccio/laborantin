
module Laborantin
  module Metaprog
    module Resolutions
      module InstanceMethods
        attr_accessor :resolutions

        def resolutions
          @resolutions ||= []
        end

        def resolve(name=nil, &blk)
          dep = Resolution.new(name, &blk)
          resolutions << dep
          dep
        end

        def resolve!(*ary)
          resolutions.map{|r| r.resolve!(*ary)}
        end
      end

      include InstanceMethods

      class Resolution
        attr_reader :name, :block
        def initialize(name, &blk)
          @name = name
          @block = blk
        end

        def resolve!(*ary)
          raise RuntimeError, "no block to resolve #{self}" unless block
          block.call(*ary)
        end
      end
    end
  end
end
