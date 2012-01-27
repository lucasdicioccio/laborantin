#runner.rb

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

require 'laborantin/runner/commands/load_classes'
require 'laborantin/runner/commands/load_results'
require 'laborantin/runner/commands/create'
require 'laborantin/runner/commands/complete'
require 'laborantin/runner/commands/describe'
require 'laborantin/runner/commands/run'
require 'laborantin/runner/commands/find'
require 'laborantin/runner/commands/scan'
require 'laborantin/runner/commands/analyze'
require 'laborantin/runner/commands/replay'
require 'laborantin/runner/commands/note'
require 'laborantin/runner/commands/cleanup'
require 'laborantin/runner/commands/rm'
require 'laborantin/runner/commands/config'
require 'laborantin/runner/commands/exports'
require 'laborantin/runner/commands/product'
require	'optparse'
require 'find'
require 'yaml'
require 'singleton'
require 'laborantin/core/configurable'

module Laborantin

  class Runner
    include Metaprog::Configurable
    include Singleton
    # The configuration of the Runner, a hash serialized in the laborantin.yaml
    # file.
    attr_accessor :config

    # The root_dir is the internal name for the working directory of a
    # Laborantin's project.
    attr_accessor :root_dir

    # Initializes the root_dir with the current working directory of the shell
    # (i.e. '.').
    def initialize 
      @root_dir = File.expand_path('.') 
    end

    # Provides a shortcut for building the correct directory path inside the root_dir.
    # Returns a string.
    # Does not check if the directory exists or is readable or anything.
    # e.g. dir(:results) or dir('results') to build the path to the result dir.
    def dir(*sym)
      File.join(root_dir, sym.map{|s| s.to_s})
    end

    def resultdir
      dir(:results)
    end

    def user_laborantin_dir
      File.join(File.expand_path('~'), '.laborantin')
    end

    def file(dir, sym)
      File.join(dir, sym)
    end

    def config_path
      file(dir(:config), 'laborantin.yaml')
    end

    def load_dir(path)
      # Verify the presence of the dir, needed for backward
      # compatibility
      if File.directory?(path) 
        Object::Find.find(path) do |file| 
          if File.extname(file) == '.rb'
            require file 
          end 
        end 
      end 
    end

    def load_user_commands
      dir = File.join(user_laborantin_dir, 'commands')
      load_dir(dir)
    end

    # Load the ruby files from the dirname directory of a Laborantin project.
    # Current implementation require all .rb files found in the commands directory.
    def load_local_dir(dirname)
      d = dir(dirname)
      load_dir(d)
    end

    def load_commands
      load_local_dir(:commands)
    end

    def load_environments
      load_local_dir(:environments)
    end

    def load_scenarii
      load_local_dir(:scenarii)
    end

    def load_analyses
      load_local_dir(:analyses)
    end

    def extra_dir
      File.join('laborantin', 'extra')
    end

    def load_extra(what, name)
      require File.join(extra_dir, what.to_s, name.to_s)
    end

    def load_extra_commands
      if config and config[:extra].is_a? Hash
        config[:extra].each_pair do |name, val|
          load_extra(:commands, name) if val
        end
      end
    end

    # Prepare a Runner by loading the configuration and the extra commands.
    def prepare
      load_config!
      load_user_commands
      load_commands
      load_environments
      load_scenarii
      load_analyses
      load_extra_commands
    end

  end

  class CliRunner < Runner

    def command_for_argv(argv)
      Command.sort_by{|c| - argv_klass_name(c).length}.find do |c|
        invokation = argv_klass_name(c)
        # does the first words on the CLI match this command's invokation?
        (argv.slice(0, invokation.size) == invokation)  
      end
    end

    def argv_klass_name(command_klass)
      ary = command_klass.command_name.split('::').map{|s| s.duck_case}

      # Strip our default command path
      ['laborantin', 'commands'].each do |prefix|
        if ary.first == prefix
          ary = ary[1 .. -1] 
        end
      end

      ary
    end

    def cli_klass_name(command_klass)
      argv_klass_name(command_klass).join(' ')
    end

    def parse_opts(argv, klass)
      extra_opts = {}

      parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($0)} #{cli_klass_name(klass)} [options...] [args...]"
        opt.banner << "\n" + klass.description
        opt.on_tail('-h', '--help', "show this help and exits") {|val| puts opt ; exit}
        klass.options.each do |arg|
          opt.on(arg.cli_short, arg.cli_long, arg.description_with_default, arg.default_type) {|val| extra_opts[arg.name] = val}
        end
      end

      remaining_args = parser.parse!(argv)

      return remaining_args, extra_opts 
    end

    def print_generic_help
      proposed = Command.reject{|cmd| cmd.plumbery?}
      parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($0)} <command> [options] [args...]\n"
        opt.banner << "Run #{File.basename($0)} <command> --help to have help on a command\n"
        opt.banner << "Known commands are: \n"
        opt.banner << proposed.map do  |klass| 
	  line = klass.description.split("\n").first.chomp
          "\t #{cli_klass_name(klass)} \n\t\t #{line}" 
        end.join("\n")
      end
      puts parser
    end

    # Actually runs the Runner. 
    # This method interprets cli as a command line where cli only contains the arguments 
    # (i.e., without the executable name).
    # The arguments are splitted as separated by splitter.
    def run_cli(cli, splitter=' ')
      run_argv(cli.split(splitter))
    end

    # Actually runs the Runner, interpreting argv like an ARGV array of strings.
    def run_argv(arguments)
      argv = arguments.dup
      prepare
      cmd_klass = command_for_argv(argv)
      if cmd_klass
        # removes the heading of argv (i.e. the part corresponding to the class name in most of the cases)
        argv_klass_name(cmd_klass).size.times do
          argv.shift()
        end

        begin
          args, opts = parse_opts(argv, cmd_klass)
          cmd = cmd_klass.new(self)
          cmd.run(args, opts)
        rescue OptionParser::InvalidOption => err
          puts err.message
          puts "use 'labor #{argv_klass_name(cmd_klass)} --help' for help"
        end
      else
        print_generic_help
      end
    end
  end
end

