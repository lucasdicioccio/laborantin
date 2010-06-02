#core/analysis.rb

=begin

This file is part of Laborantin.

Laborantin is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Laborantin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Laborantin.  If not, see <http://www.gnu.org/licenses/>.

Copyright (c) 2009, Lucas Di Cioccio

=end

autoload :ERB, 'erb'

module  Laborantin
  # An Analysis is a handy way to reload and filter the various scenarii that were
  # run. You can easily filter on them.
  class Analysis
    class << self
      # A description string.
      attr_accessor :description

      # A hash with two items, this might change later but KISS for now.
      attr_accessor :selectors

      # An array
      attr_accessor :analyses

      # Sets the description string of the analysis.
      def describe(str)
        @description = str
      end

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

      # Adds an analysis to this class.
      # str is a description of the added analysis params is a hash of
      # parameters for this analysis, specifically, the :type parameters allows
      # you to differenciate the kind of analysis for repors TODO: more info on
      # that, tells that we can directly use Analysis.plot and Analysis.table
      # methods
      def analyze(str, params = {}, &blk) 
        @analyses << {:str => str, :params => params, :blk => blk} 
      end

      def plot(title, args, &blk)
          args ||= {}
          hash = args.merge({:type => :plot})
          analyze(title, hash, &blk)
      end

      def table(title, args, &blk)
          args ||= {}
          hash = args.merge({:type => :table})
          analyze(title, hash, &blk)
      end

      def plots
        analyses.select{|a| a[:params][:type] == :plots}
      end

      def tables
        analyses.select{|a| a[:params][:type] == :tables}
      end

      @@all = []

      def inherited(klass)
        @@all << klass
        klass.select(:environments,[Laborantin::Environment])
        klass.select(:scenarii,[Laborantin::Scenario])
        klass.analyses = []
      end

      def all
        @@all
      end
    end # << self

    # An array of the Environments that could be loaded from the result directory.
    attr_accessor :environments

    # An array of the Scenarii that could be loaded from the result directory.
    attr_reader :scenarii

    # TODO : recode this, maybe as nothing to do here
    def analyze 
      self.class.analyses.each do |a|
        puts "analyzing #{a[:str]}"
        instance_eval &a[:blk]
        puts "done"
      end
    end

    # TODO: more flexible
    def report(tpl_path=nil)
      tpl = ERB.new(File.read(tpl_path))
      File.open("reports/#{self.class.name}.html", 'w') do |f|
        f.puts tpl.result(binding)
      end
    end

    private

    # Just loads the environments and scenarii from the resultdir.
    def initialize(*args, &blk)
      load_from_results
      set_instance_vars
    end

    # Load first the environments, then the scenarii.
    def load_from_results
      load_environments
      load_scenarii
    end

    # Sets the various handy instance variables:
    # * @plots
    # * @tables
    def set_instance_vars
      @plots = self.class.plots.dup
      @tables = self.class.tables.dup
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
      blk = selector[:blk]
      (selector[:klasses].any?{|k| obj.is_a? k} ) and
      (blk ? blk.call(obj) : true)
    end

    # Nice way to iterate on @scenarii
    def each_scenario
      @scenarii.each do |sc|
        yield sc
      end
    end

    # Nice way to iterate on @environments
    def each_environment
      @environments.each do |env|
        yield env
      end
    end

  end
end
