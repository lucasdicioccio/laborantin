#core/scenario.rb

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

require 'laborantin/core/parameter'
require 'laborantin/core/parameter_hash'

autoload :FileUtils, 'fileutils'
autoload :YAML, 'yaml'

require 'laborantin/core/datable'
require 'laborantin/core/describable'
require 'laborantin/core/hookable'
require 'laborantin/core/configurable'

module Laborantin

  # A Scenario represents a measurement done in a given environment. Some of
  # its parameters will change, and we are interested in varying these parameters and
  # then study their impact.
  #
  # An user will usually creates a Scenario subklass which represents such 
  # a measurement. For that he must defines a run method that will yield consecutive
  # lines added to the raw result file. Then this file can be processed to give 
  # intermediary or final results.
  #
  # Like the Environment, all the subklasses will be stored in a @@all 
  # class variable for convenience purpose.
  class Scenario
    include Metaprog::Datable
    include Metaprog::Configurable
    extend Metaprog::Describable
    extend Metaprog::Hookable
    @@all = []

    # Scans the env's envdir (should be an Environment) for scenarii results.
    # It will set their configuration (i.e. run date and parameters hash)
    # according to the stored config.yaml in YAML format.  Returns an array of
    # such built scenarii.
    def self.scan_env(env)
      list = []
      Dir.entries(env.rundir).each do |s|
        scklass = Laborantin::Scenario.all.find{|t| t.name.duck_case == s}
        if scklass
          Dir.entries(scklass.scenardir(env)).each do |r|
            if r =~ /\d+-\w+-\d+_\d+-\d+-\d+/
              scenar = scklass.new_loading_from_dir(env, File.join(scklass.scenardir(env), r))
              list << scenar
            end
          end
        end
      end
      list
    end

    def self.new_loading_from_dir(env, path)
      obj = self.new(env)
      tst, params = obj.load_config!
      obj.params = params
      obj.date = tst
      obj.rundir = path
      obj
    end

    class << self
      # The set of parameters that will vary for this Scenario.
      attr_accessor :parameters

      # Some special products that are done after an analysis on a measurement
      # scenario. The intended way is to store raw results (e.g. a command output) in
      # a file and then parse them and store the parsed result in another file etc.
      # TODO : products that compares scenarii
      attr_accessor :products

      # Prepares attributes' default values whenever a subclass is created.
      def inherited(klass)
        klass.parameters = ParameterHash.new
        klass.description = ''
        klass.products = []
        klass.hooks = {:setup => [], :teardown => []}
        @@all << klass
      end

      # Defines a new ParameterRange instance for this Scenario.
      # A block should be passed that will be evaluated in this 
      # ParameterRange instance's context.
      #
      #   parameter(:size) do
      #     values 10, 20, 30
      #     describe "We expect a linear RTT increase with the size"
      #   end
      #
      def parameter(name, &blk)
        raise ArgumentError.new("Parameter #{name} already exists") if self.parameters[name]
        param = ParameterRange.new(name)
        param.instance_eval &blk
        self.parameters[name] = param
      end

      # Defines the products names.
      # IMPORTANT: products are built in the provided order, and they must be 
      # valid instance methods name for a Scenario object (hence user defined).
      def produces(*args)
        self.products = [*args].flatten
      end

      # Returns all the known subklasses of Scenario.
      def all
        @@all
      end

      # Returns the path where the results of the instances of this Scenario
      # will be stored given that we are in the env Environment. If env is nil,
      # will use '.' as rootdir for the Scenario results.
      def scenardir(env=nil)
        envdir = env.rundir || '.'
        File.join(envdir, self.name.duck_case)
      end
    end # class << 

    # A hash of parameters for this run.
    attr_accessor :params

    # The environment in which we run this scenario.
    attr_accessor :environment

    # An attribute that holds the directory where the config and the results
    # are stored. Can be overridden (e.g. Scenario.scan_env does that).
    attr_accessor :rundir

    # Initializes a new instance contains in the env Environment, and 
    # for the parameter set params.
    # Sets the date to Time.now for unicity (with 1sec granularity)
    # Sets the rundir accessor in the directory.
    # Does NOT create any directory, so the accessors can be overwritten if needed.
    def initialize(env, params={})
      @environment = env
      @params = params
      @date = Time.now
      @config = {}
      @rundir = File.join(self.class.scenardir(environment), date_str)
    end

    # In the following order:
    # * Log some info in the environment
    # * Creates the rundir to store the result and the config
    # * Stores the configuration as well as the run date
    # BEWARE : currently does not ensure unicity of rundir, 
    # so wait one sec between several runs of same Scenario
    #
    def prepare!
      log(self.class.description, :info) unless self.class.description.empty?
      log self.params.inspect, :info
      log "Preparing directory #{rundir}"
      FileUtils.mkdir_p(rundir)  #TODO: ensure unicity
      environment.record_scenario_dir(rundir, true)
      log "Storing configuration in YAML format"
      @config = [date, params]
      save_config
    end

    # In the following order:
    # * Calls the setup hooks
    # * Logs some info
    # * Creates the raw result file
    # * Calls the run method (user defined)
    # * ... for each yielded line, store it into the raw result file
    # * once completed (or on error) closes the raw result file
    # * Logs some info
    # * Calls the teardown hooks
    def perform!
      call_hooks :setup
      log "Starting measurement"
      raw_result_file('w') do |f|
        run do |l|
          f.puts l
        end
      end
      log "Measurement finished"
      call_hooks :teardown
    end

    # For each product define with Scenario.produces, and in its order,
    # create a file with a canonic name in the scenario rundir.
    # Call the instance method which has the product name.
    # Appends each yielded line from this method.
    def analyze!
      self.class.products.each do |name|
        log "Producing #{name}"
        product_file(name.to_s, 'w') do |f|
          send(name) do |l|
            f.puts l
          end
        end
        log "Product #{name} done"
      end
    end

    # Returns the absolute path to a product file (see File.join) If brutname
    # is true, then resultname is appended to the rundir of the scenario.  If
    # brutname is false, then before being appended to the rundir of the
    # scenario, the name is surronded by result.<resultname>.txt 
    #
    # The idea behind this is to avoid name collisions between simple users of
    # Laborantin, and people developping extensions or modules.
    def product_path(resultname, brutname=false)
      resultname = "result.#{resultname}.txt" unless brutname
      File.join(rundir, resultname)
    end

    # Yields an open file for a given product, will make sure it is closed.
    # mode is the mode in which the file is opened (you should leave it to 'r')
    # see the doc for product_path to understand the role of brutname
    def product_file(resultname, mode='r', brutname=false)
      File.open(product_path(resultname, brutname), mode) do |f|
        yield f
      end
    end

    # The path to the config.yaml file that holds the scenario parameters.
    def config_path
      product_path('config.yaml', true)
    end

    # The path to the "raw result", i.e. the one built when you yield in the
    # run method.
    def raw_result_path
      product_path('result.raw', true)
    end

    # Yield the opened raw result file, will close it afterwards.
    # mode is the mode in which the file is opened (default to 'r')
    # never open the file in another mode, unless you know what you're doing,
    # because this file most likely contains the value of your work, i.e., your
    # data.
    def raw_result_file(mode='r')
      product_file('result.raw', mode, true) do |f| 
        yield f
      end
    end

    private

    def call_hooks(name)
      log "Calling #{name} hooks"
      self.class.hooks[name].each{|sym| send sym}
    end

    def log(*args)
      environment.log *args
    end

  end # class
end
