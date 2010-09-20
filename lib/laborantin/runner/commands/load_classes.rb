#runner/commands/load_classes.rb

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

require 'logger'
require 'fileutils'

module Laborantin
  module Commands
    class LoadClasses < Command
      describe "Plumbery command to load classes."
      plumbery!

      option(:scenarii) do
        describe "comma separated list of scenarios classes to load"
        short "-s"
        long "--scenarii=OPTIONAL"
        type Array
        default []
      end

      option(:environments) do
        describe "comma separated list of environments classes to load"
        short "-e"
        long "--envs=OPTIONAL"
        type Array
        default []
      end

      execute do
        # Environments and Scenarii filtering
        envklasses = if opts[:environments].empty?
                       Laborantin::Environment.all
                     else
                       Laborantin::Environment.all.select do |e| 
                         opts[:environments].find do |cli_name| 
                           cli_name == e.cli_name
                         end
                       end
                     end

        sciiklasses = if opts[:scenarii].empty?
                        Laborantin::Scenario.all
                      else
                        Laborantin::Scenario.all.select do |sc|
                          opts[:scenarii].find do |cli_name|
                            cli_name == sc.cli_name
                          end
                        end
                      end

        {:envs => envklasses, :scii => sciiklasses}
      end
    end
  end
end
