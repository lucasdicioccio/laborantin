#runner/commands/load_results.rb

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
    class LoadResults < Command
      describe "Plumbery command to load results."
      plumbery!

      VERSIONS = ['0.0.20']

      option(:version) do
        describe "the Laborantin version's loader to use #{VERSIONS.inspect}"
        short '-v'
        long "--version=OPTIONAL"
        type String
        default Laborantin::VERSION
      end

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

      option(:successful_only) do
        describe "only load successful results"
        long '--successful'
        default false
      end

      option(:failed_only) do
        describe "filter out results in sucessfuls environments"
        long '--failed'
        default false
      end

      option(:after_date) do
        describe "filter only environments which date is later than"
        long '--after=OPTIONAL'
        type String
        default ''
      end

      option(:before_date) do
        describe "filter only environments which date is earlier than"
        long '--before=OPTIONAL'
        type String
        default ''
      end

      def keep_env?(e, classes)
        (classes[:envs].find{|k| e.is_a? k}) and
        ((opts[:successful_only] ? e.successful? : true) and
         (opts[:failed_only] ? e.failed? : true))
      end


      execute do
        sym = unless VERSIONS.include?(opts[:version])
                :execute_latest
              else
                "execute_#{opts[:version]}"
              end
        send sym 
      end

      define_method(:"execute_0.0.20") do
        # Parameters parsing
        params = eval(opts[:parameters]) unless opts[:parameters].empty?
        params ||= {}
        params.each_key{|k| params[k] = [params[k]].flatten}

        # Loading classes
        classes = Laborantin::Commands::LoadClasses.new.run([], opts)

        # Loading results now
        envs = Laborantin::Environment.scan_resdir('results').select do |e| 
          keep_env?(e, classes)
        end
        all_scii = envs.map{|env| env.populate }.flatten.select{|sc| classes[:scii].find{|k| sc.is_a? k}}

        # Filtering the scenarii
        scii = all_scii.select do |sc|
          filter_out = params.keys.find do |k| 
            not params[k].include?(sc.params[k])
          end
          not filter_out
        end

        {:envs => envs, :scii => scii}
      end

      alias :execute_latest :"execute_0.0.20"
    end
  end
end
