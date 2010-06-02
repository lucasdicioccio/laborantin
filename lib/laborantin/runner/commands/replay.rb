#runner/commands/replay.rb

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
    class Replay < Command
      describe "Reproduces the scenarios' product for scenarios that match the filter"

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

      option(:methods) do
        describe "list of methods to call, default to all the products"
        short '-m'
        long '--methods=OPTIONAL'
        type Array
        default []
      end

      execute do
        results = Laborantin::Commands::LoadResults.new.run([], opts)

        logger = Logger.new(STDOUT)
        results[:envs].each{|env| env.loggers << logger}

        results[:scii].each do |sc|
          sc.environment.log "#{sc.environment.class.name} - #{sc.class.name}", :info
          sc.environment.log "Replaying products #{sc.params.inspect}"
          if opts[:methods].empty?
            sc.analyze!
          else
            opts[:methods].each{ |meth| sc.send meth }
          end
        end
      end # execute
    end
  end
end

