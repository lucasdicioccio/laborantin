#runner/commands/scan.rb

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

require 'laborantin'
require 'fileutils'

module Laborantin
  module Commands
    class Scan < Command
      describe "Prints a Summary of the various scenarios/environments performed"

      option(:scenarii) do
        describe "comma separated list of scenarios to describe"
        short "-s"
        long "--scenarii=OPTIONAL"
        type Array
        default []
        complete do |cmd|
          completion_propositions_iterating_on(cmd, Laborantin::Scenario.all.map(&:cli_name))
        end
      end

      option(:environments) do
        describe "comma separated list of environments to describe"
        short "-e"
        long "--envs=OPTIONAL"
        type Array
        default []
        complete do |cmd|
          completion_propositions_iterating_on(cmd, Laborantin::Environment.all.map(&:cli_name))
        end
      end

      option(:parameters) do
        describe "filter for parameters (a hash as Ruby syntax code)"
        short '-p' 
        long '--parameters=OPTIONAL'
        type String
        default ''
      end

      execute do
        results = Laborantin::Commands::LoadResults.new.run([], opts)
        puts "Laborantin's summary:"
        Laborantin::Environment.all.each do |envklass|
          env_tot = results[:envs].select{|e| e.is_a? envklass}.size #XXX instead of .count
          puts "#{envklass.cli_name} => #{env_tot}"
          Laborantin::Scenario.all.each do |scklass|
	    sc_tot = results[:scii].select{|s| s.is_a? scklass and s.environment.is_a? envklass}.size #see above
            puts "\t#{scklass.cli_name} => #{sc_tot}"
          end
        end

      end #execute
    end
  end
end
