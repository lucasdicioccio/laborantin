
module Laborantin
  module Metaprog
    module Selector
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        # A hash with two items, this might change later but KISS for now.
        attr_accessor :selectors

        # Add a selector to filter for the analysis only the runs that pass the selector.
        # * sym objects (sym currently must be :environments or 
        # :scenarii).
        # * ary is a set of classes, only runs of this classes will be loaded
        # * if a block is passed, only the instances for which the block is
        # evaluated as true will be selected  (the block must take one parameter:
        # the tested instance)
        def select(sym, ary=[], &blk) 
          @selectors ||= {} 
          @selectors[sym] = {:klasses => ary, :blk => blk} 
        end
      end

      # An array of the Environments that could be loaded from the result directory.
      attr_accessor :environments

      # An array of the Scenarii that could be loaded from the result directory.
      attr_reader :scenarii

      # Load first the environments, then the scenarii.
      def load_prior_results
        load_environments
        load_scenarii
      end

      # Will try to load environments and set the @environments variable to an
      # array of all the Environment instance that match the :environments class
      # selector (set with Analysis#select).
      def load_environments 
        envs = Laborantin::Environment.scan_resdir('results')
        @environments = envs.select do |env| 
          select_instance?(env, self.class.selectors[:environments])
        end 
      end

      # Same as load_environments, but for Scenario instances and :scenarii
      # selector.
      def load_scenarii
        scii = @environments.map{|e| e.populate}.flatten
        @scenarii = scii.select do |sc|
          select_instance?(sc, self.class.selectors[:scenarii])
        end
      end

      # Handy test to see if an object (that should be an instance of Environment
      # or Scenario) matches the selector.
      def select_instance?(obj, selector)
        return true unless selector
        blk = selector[:blk]
        (selector[:klasses].any?{|k| obj.is_a? k} ) and
        (blk ? blk.call(obj, self) : true)
      end

    end
  end
end
