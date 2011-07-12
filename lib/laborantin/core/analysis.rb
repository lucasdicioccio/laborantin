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

require 'laborantin/core/describable'
require 'laborantin/core/multi_name'
require 'laborantin/core/selector'
require 'laborantin/core/dependencies'

module  Laborantin
  # An Analysis is a handy way to reload and filter the various scenarii that were
  # run. You can easily filter on them.
  class Analysis
    extend Metaprog::Describable
    extend Metaprog::MultiName
    include Metaprog::Selector
    include Metaprog::Dependencies

    class << self
      # An array
      attr_accessor :analyses

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

    # TODO : recode this, maybe as nothing to do here
    def analyze 
      self.class.analyses.each do |a|
        puts "(#{a[:str]})"
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

    def output_dirname
      self.class.cli_name
    end

    def output_dirpath
      File.join('.', 'reports', output_dirname)
    end

    def create_output_dir
      FileUtils.mkdir_p(output_dirpath) unless File.directory?(output_dirpath)
    end

    def output_path(name)
      File.join(output_dirpath, name)
    end

    def output(name, mode='r')
      create_output_dir
      File.open(output_path(name), mode) do |f|
        yield f
      end
    end

    def table(name, struct)
      Table.new(name, struct, self.output_path(name))
    end

    attr_reader :command

    # Just loads the environments and scenarii from the resultdir.
    def initialize(command = nil)
      @command = command
      load_prior_results
      set_instance_vars
    end

    def runner
      command.runner if command
    end

    private

    # Sets the various handy instance variables:
    # * @plots
    # * @tables
    def set_instance_vars
      @plots = self.class.plots.dup
      @tables = self.class.tables.dup
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

    # The list of parameters spanned from the scenarii.
    # e.g. scenario 1, params = A => a1, B => b1
    #      scenario 2, params = A => a2, B => b2
    #      scenario 3, params = C => c3
    #      parameters = A => [a1, a2], B => [b1, b2], C => [c3]
    def parameters
      unless @parameters
        @parameters = {}
        each_scenario do |sc|
          sc.params.each_pair do |name, value|
            @parameters[name] ||= []
            @parameters[name] << value unless @parameters[name].include?(value)
          end
        end
      end
      @parameters
    end

  end
end
