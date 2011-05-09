#runner/commands/run.rb

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
require 'logger'
require 'fileutils'

module Laborantin
  module Commands
    class Run < Command
      describe 'Runs all set of scenarios and environments'

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

      option(:analyze) do
        describe "set this flag to analyze as you run"
        short '-a'
        long '--analyze'
        default false
      end

      option(:continue) do
        describe "run in continue mode, that is, skip parameter configurations that matches a scenario among the results"
        short '-c'
        long '--continue-mode'
        default false
      end

      execute do
        # Parameters parsing
        params = eval(opts[:parameters]) unless opts[:parameters].empty?
        params.each_key{|k| params[k] = [params[k]].flatten} if params

        classes = Laborantin::Commands::LoadClasses.new.run([],opts)
        results = if opts[:continue]
                    Laborantin::Commands::LoadResults.new.run([],opts)
                  else
                    {:scii => []}
                  end

        # Actual run of experiments
        classes[:envs].each do |eklass|
          env = eklass.new(self)
          if env.valid?
            begin
              env.prepare!
              env.log "Running matching scenarii", :info #TODO: this is weird
              env.state = :run
              classes[:scii].each do |sklass|
                sklass.parameters.merge!(params) if params
                env.log sklass.parameters.inspect
                sklass.parameters.each_config do |cfg|
                  sc = results[:scii].find do |s| 
                    (s.params == cfg) and
                    (s.class == sklass) and
                    (s.environment.class == eklass)
                  end
                  if sc
                    puts "skipping #{cfg} found in #{sc.rundir}"
                    next
                  end

                  sc = sklass.new(env, cfg)
                  sc.prepare!
                  sc.perform!
                  sc.analyze! if opts[:analyze]
                end
              end
              env.teardown!
              env.state = :success
              env.log "Scenarii performed", :info
            rescue Exception => err
              env.log err.to_s, :warn
              env.state = :error
              raise err
            end
          end
        end
      end
    end
  end
end

