
#$DEBUG = true

module Laborantin
  module Commands
    class Complete < Laborantin::Command
      describe "completes a command line"
      plumbery!

      def maps_to_a_klass?(cmd)
        runner.command_for_argv(cmd.split(' '))
      end

      def list_mapping_klasses(str)
        #separate the case for modules
        # labor config <tab>
        # should propose config set|foo
        if str == 'labor'
          Command.reject(&:plumbery?).map{|cmd| runner.argv_klass_name(cmd).first}
        else
          size = str.split.size
          cmds = Command.reject{|cmd| cmd.plumbery?}.map do |cmd|
            runner.argv_klass_name(cmd).slice(0, size)
          end

          match = cmds.find do |cmd|
            cmd.join(' ') == str
          end

          if match
            cmds = Command.reject{|cmd| cmd.plumbery?}.map do |cmd|
              runner.argv_klass_name(cmd).slice(0, size+1)
            end
          end

          cmds.select do |cmd|
            tst = cmd.join(' ').start_with?(str) 
            STDERR.puts "#{cmd} | #{str} | #{tst}" if $DEBUG
            tst 
          end.map do |cmd|
            cmd.last
          end
        end
      end

      def complete_option(opt, cmd)
        opt.completion_block.call(cmd) if opt.completion_block
      end

      def list_long_option(klass, cmd)
        # in the options of the command look for the one with long
        opt = klass.options.find{|o| o.cli_long == cmd.split.last}

        if opt 
          complete_option(opt,cmd)
        else
        end
      end

      def list_short_option(klass, cmd)
        # in the options of the command look for the one with long
        opt = klass.options.find{|o| o.cli_short == cmd.split.last}
        if opt 
          complete_option(opt,cmd)
        else
          if cmd.split[-2].start_with?('-')
            opt = klass.options.find{|o| o.cli_short == cmd.split[-2]}
            complete_option(opt,cmd) if opt
          else
            klass.options.map(&:cli_short).select{|w|
              w.start_with?(cmd)
            }
          end
        end
      end

      def list_argv_and_options_line(klass, cmd)
        klass.completion_block.call(cmd) if klass.completion_block
      end

      execute do |me|
        STDERR.puts me.args if $DEBUG
        cmd = STDIN.read.chomp
        arg = me.args
        cmd = cmd.sub(/^labor\s+/,'')

        klass = maps_to_a_klass?(cmd)
        list = if klass
                 if cmd.split.last.start_with?('--')
                   list_long_option(klass, cmd)
                 elsif cmd.split.last.start_with?('-')
                   list_short_option(klass, cmd)
                 elsif cmd.split[-2] and cmd.split[-2].start_with?('--')
                   list_long_option(klass, cmd)
                 elsif cmd.split[-2] and cmd.split[-2].start_with?('-')
                   list_short_option(klass, cmd)
                 else
                   list_argv_and_options_line(klass, cmd)
                 end
               else
                 # complete finding a class
                 list_mapping_klasses(cmd)
               end

        list ||= []

        puts list.compact.uniq.join("\n")
      end
    end
  end
end
