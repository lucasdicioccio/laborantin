#runner/commands/find.rb

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
    class Find < Command
      describe "Finds and prints the result dir for a set of parameters / environments / scnarios"

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

      option(:successful_only) do
        describe "filter out results in failed environments"
        long '--successful'
        default false
      end

      option(:failed_only) do
        describe "filter out results in sucessfuls environments"
        long '--failed'
        default false
      end

      execute do
        results = Laborantin::Commands::LoadResults.new.run([], opts)
        results[:scii].each do |sc|
          puts "#{sc.rundir} #{sc.params.inspect}"
        end
      end # execute
    end
  end
end
