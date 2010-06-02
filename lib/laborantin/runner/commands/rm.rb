#runner/commands/rm.rb

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

module Laborantin
  module Commands
    class Rm < Command
      describe "Removes the result directories of the matching scenarios and cleanup empty environments results directories"

      option(:scenarii) do
        describe "comma separated list of scenarios to describe"
        short "-s"
        long "--scenarii=OPTIONAL"
        type Array
        default []
      end

      option(:environments) do
        describe "comma separated list of environments to describe"
        short "-e"
        long "--envs=OPTIONAL"
        type Array
        default []
      end

      option(:parameters) do
        describe "filter for parameters (a hash as Ruby syntax code)"
        short '-p'
        long '--parameters=OPTIONAL'
        type String
        default ''
      end

      option(:force) do
        describe "disable check that prevents removing everything when there is no option on the CLI"
        short '-f'
        long '--force'
        default false
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

      def has_listed_parameters?
        [:environments, :scenarii, :parameters].map{|i| opts[i].empty?}.include?(false)
      end

      def has___only_parameter?
        (opts[:failed_only] == true) or (opts[:successful_only] == true)
      end

      def at_risk?
        (not has_listed_parameters?) and
        (not has___only_parameter?)
      end

      execute do
        if at_risk?
          #i.e., if there is no option on the CLI (matches all results)
          unless opts[:force]
            puts "This is at risk, please set the force flag."
            exit
          end
        end
        results = Laborantin::Commands::LoadResults.new.run([],opts)
        results[:scii].each do |sc|
          FileUtils.rm_rf(sc.rundir, :verbose => true)
        end
        Laborantin::Commands::Cleanup.new.run([],{})
      end
    end
  end
end
