#core/command.rb

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

require 'laborantin/core/completeable'

module Laborantin
  # The Command is a way to extend the labor script to help you modularize your
  # work, and call the commands both via the command line, or in your scripts.
  # This class provides parsing facilities. Namespacing (i.e., mapping between
  # classes and command line is done in the Runner .  Internal labor Commands
  # are actually implemented this way.
  class Command

    # An Option for a Command, to help us building a nice DSL for you.
    class Option

      include Metaprog::Completeable

      # The name of the option.
      attr_reader :name
      
      # The short option flag of the command line (e.g. '-t')
      attr_reader :cli_short
      
      # The long option flag of the command line (e.g. '--trust')
      attr_reader :cli_long
      
      # The description to provide feedback/help.
      attr_reader :description
     
      # The default value of this option.
      attr_reader :default_value
     
      # The type to expect for a value (give a class among those understood by OptParse)
      attr_reader :default_type

      def initialize(name)
        @name = name
      end

      # Sets the cli_short option flag (e.g. short '-t')
      def short(str)
        @cli_short = str
      end

      # Sets the cli_long option flag (e.g. long '--trust')
      def long(str)
        @cli_long = str
      end

      # Sets the description of the option.
      def describe(str)
        @description = str
      end

      # Sets the default value of the option.
      def default(val)
        @default_value = val
      end

      # Sets the type to expect for the option.
      def type(klass)
        @default_type = klass
      end

      # Returns the description followed by the default value in parenthesis.
      def description_with_default
        "#{description} (default: #{default_value})."
      end
    end

    # An Array to store all the commands.
    @@all = []

    extend Enumerable

    # Once we've extended Enumerable, it's easy to find new commands.
    def self.each
      @@all.each{|e| yield e}
    end

    class << self

      include Metaprog::Completeable

      # The description string of a command, will be used on command line help.
      attr_accessor :description

      # Wether or not this command is a plumbery one.
      attr_accessor :plumbery
      
      # An Array contining the possible options of this command.
      attr_accessor :options
     
      # The block of execution for the instances of this commands.
      # By default, this will raise an exception.
      # TODO: transform the block into a default method.
      attr_accessor :block
     
      # The command name, can be set, this is useful when the class has no name
      # (e.g. an object created with Class.new(Command)), or if you want to use
      # another name for this command.
      attr_accessor :command_name

      # By default, the name of the class, or an empty string if none (this can
      # lead to big issues, so I'm still considering returning nil if a command
      # has no name nor command_name.
      def command_name
        (@command_name || self.name ) || ''
      end

      # When a new Command class is created, sets up default value, and store
      # the new class in the known commands.
      def inherited(klass)
        klass.description = ''
        klass.options = []
        klass.block = lambda { raise RuntimeError.new("no execution block for #{klass}") }
        @@all << klass
      end

      # Set the description string.
      def describe(str=nil)
        self.description = str
      end

      # Sets the plumbery flag.
      def plumbery!(val=true)
        self.plumbery = val
      end

      # Returns true if the plumbery flag is true.
      def plumbery?
        self.plumbery && true
      end

      # Opposite of plumbery?
      def porcelain?
        not self.plumbery?
      end

      # Set the execution block (executed in the scope of the instance).
      # XXX this might well be changed into requiring ppl to define an "execute" method.
      def execute(&blk)
        self.block = blk
      end

      # Assign a new option to this command class, which name is name
      # (preferably, give Symbol or String).  The blk is evaluated in the scope
      # of a new Option instance.
      # Giving a name is required, because it is also the key of the command.opts hash.
      def option(name, &blk)
        arg = Option.new(name) 
        arg.instance_eval &blk
        self.options << arg
      end
    end # << self

    # A hash containing a merge of the defaults options of the class and the
    # extra options provided to the run method.
    # Think of it like the '--path=/some/path' options of a command line.
    # Options are labeled but not ordered, arguments are the opposite.
    attr_reader :opts

    # An array containing the arguments of the command. 
    # Think of it like the trailing arguments of a command line.
    # Arguments are ordered but not labeled, options are the opposite.
    attr_reader :args

    # The Runner object that will executes the command.
    attr_accessor :runner

    # Initializes a new instance of command.  Will first set the runner if
    # provided, then will initialize default options and arguments.
    def initialize(runner=nil)
      @runner = runner
      initialize_opts
      initialize_args
    end

    # Runs the command by merging the options with extra_opts and evaluating
    # the block stored in the class.
    def run(args=[], extra_opts={})
      @opts.merge!(extra_opts)
      @args = args
      self.instance_eval &self.class.block
    end

    # Forward a line to the runner if it respond to a puts method too.
    # Fallback on Kernel.puts if there is no runner or the runner does 
    # not respond to puts.
    def puts(line)
      if runner and runner.respond_to?(:puts)
        runner.puts(line)
      else
        Kernel.puts(line)
      end
    end

    private

    # Just initialize the opts to an empty Array
    def initialize_args
      @args = []
    end

    # Grabs the default values of the options from the class of the command.
    def initialize_opts
      @opts = {}
      self.class.options.each do |arg|
        @opts[arg.name] = arg.default_value
      end
    end
  end
end
