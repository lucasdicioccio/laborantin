#core/environment.rb

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

autoload :Time, 'time'
autoload :Logger, 'logger'
autoload :FileUtils, 'fileutils'

require 'laborantin/core/datable'

module Laborantin

  # An Environment represents the surrounding of an experiment. Basically, it
  # should only contains things that are hard to change during an experiment.
  # Let's say you have two computers, A and B. A can be a server and B a client
  # or vice-versa. Hence, this is a good choice for two differents environments.
  #
  # As a normal user, you should only subclass Environment, and let the script
  # creates it for you. But it is easy to monkey-patch or to subclass by hand.
  # If you want to do that, you must know that Environment @@all class variable
  # holds a reference to every child class from Environment.
  class Environment
    include Metaprog::Datable

    @@all = []

    # Populates loaded (i.e. put in @@all class variable when self.inherited 
    # is called) environment classes from existing results that are stored in
    # the dir parameter.
    def self.scan_resdir(dir)
      ret = []
      Dir.entries(dir).each do |f| 
        envklass = Laborantin::Environment.all.find{|e| e.name.duck_case == f} 
        if envklass
          Dir.entries(envklass.envdir).each do |e|
            if e =~ /\d+-\w+-\d+_\d+-\d+-\d+/
              env = envklass.new #XXX don't prepare! it hence don't overwrite logs
              env.rundir = File.join(envklass.envdir, e)
              env.load_config!
              ret << env
            end
          end
        end
      end
      ret
    end

    class << self

      # An array of methods called to ensure that the environment run is the
      # wanted one (e.g. a way to specify a RUBY_PLATFORM).
      # CURRENTLY NOT HERITED
      attr_accessor :verifications

      # A description used for printing summary and debug purposes. Will be 
      # used to create .tex report in the future.
      # CURRENTLY NOT HERITED
      attr_accessor :description

      # A hash to store setup/teardown hooks.
      # CURRENTLY NOT HERITED
      attr_accessor :hooks

      # Prepares attributes' default values whenever a subclass is created.
      def inherited(klass)
        klass.verifications = []
        klass.description = ''
        klass.hooks = {:setup => [], :teardown => []}
        @@all << klass
      end

      # Registers new verifiers methods that will be verified at beginning.
      def verify(*args)
        self.verifications = [*args].flatten
      end

      # Sets the description.
      def describe(str)
        self.description = str
      end

      # Registers setup hooks, called before any scenario is instantiated.
      def setup(*args)
        self.hooks[:setup] = [*args].flatten
      end

      # Registers teardown hooks, called after every scenarii has been 
      # performed and analyzed.
      def teardown(*args)
        self.hooks[:teardown] = [*args].flatten
      end

      # Output a string with name and description indented.
      def to_s
        "#{self.name}:\n\t#{self.description}"
      end

      # Returns all the known subklasses of Environment.
      def all
        @@all
      end

      # The path where the results for instance of a subklass of Environment
      # are stored (needs the Runner's resultdir).
      def envdir
        File.join(Runner.instance.resultdir, self.name.duck_case)
      end
    end

    # An attribute that holds the directory where the logfile and the scenarii results
    # are stored. Can be overridden (e.g. Environment.scan_resdir does that).
    attr_accessor :rundir

    # An array of loggers objects.
    attr_accessor :loggers

    # A hash placeholder for extra config (e.g. git revision for the git implementation)
    attr_accessor :config

    # Initializes a new instance:
    # the date is Time.now
    # the rundir is the Environment.envdir followed by the date_str
    # the loggers contains an empty Array
    # Does NOT create any directory, so the accessors can be overwritten if needed.
    def initialize
      @date = Time.now
      @rundir = File.join(self.class.envdir, date_str)
      @loggers = []
      @config = {}
    end

    # sends all the methods registered in Environment.verify
    # returns the method symbol of the failed verification if any
    def valid?
      self.class.verifications.find{|v| not send(v)}.nil?
    end

    # complete path to the environment.log file
    def logfile_path
      File.join(rundir, 'environment.log')
    end

    # complete path to the config.yaml file
    def configfile_path
      File.join(rundir, 'config.yaml')
    end

    # saves the @config in a YAML configfile
    def save_config
      File.open(configfile_path, 'w') do |f|
        f.puts YAML.dump(config)
      end
    end

    # restore the configuration from the configfile
    def load_config!
      @config = YAML.load_file(configfile_path)
    end

    # gets the state of the environment
    def state
      config[:state]
    end

    # changes the state of the environment
    def state=(val, save=true)
      config[:state] = val
      save_config if save
    end

    # returns if the environment succeeded
    def successful?
      config[:state] == :success
    end

    # returns if the environment exited with error
    def failed?
      config[:state] == :error
    end

    # In the following order:
    # * Creates the envdir if needed.
    # * Adds some loggers.
    # * Calls the setup hooks methods
    # BEWARE : currently does not ensure unicity of envdir, 
    # so wait one sec between several runs of same env
    #
    def prepare!
      FileUtils.mkdir_p(rundir) #TODO: ensure unicity
      @loggers << Logger.new(logfile_path)
      @loggers << Logger.new(STDOUT)
      log(self.class.description, :info) unless self.class.description.empty?
      log "Directories prepared"
      log "Writing config file"
      save_config
      call_hooks :setup
    end

    # Calls the teardown hooks methods.
    def teardown!
      call_hooks :teardown
    end

    # Send str log message at the levele lvl to every loggers.
    def log(str, lvl=:debug)
      @loggers.each{|l| l.send(lvl, str)}
    end

    # Returns an array of Scenario objects from the results in the envdir.
    # The scenarii classes must be loaded before, else, some results might be ignored.
    def populate
      Laborantin::Scenario.scan_env(self)
    end

    private

    def call_hooks(name)
      log "Calling #{name} hooks"
      self.class.hooks[name].each{|sym| send sym}
    end

  end # class
end # module
