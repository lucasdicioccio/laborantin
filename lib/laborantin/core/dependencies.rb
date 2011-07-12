
require 'laborantin/core/verifications'

module Laborantin
  module Metaprog
    module Dependencies
      class Dependency
        include Metaprog::Describable
        include Metaprog::Verifications
        attr_reader :name
        def initialize(name)
          @name = name
        end
      end

      def self.included(klass)
        klass.extend ClassMethods
        klass.dependencies = []
      end

      module ClassMethods
        attr_accessor :dependencies

        def dependencies
          @dependencies ||= []
        end

        def dependency(name,&blk)
          dep = Dependency.new(name)
          dep.instance_eval &blk
          dependencies << dep
          dep
        end
      end
    end
  end
end
