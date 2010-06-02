#runner/commands/describe.rb

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

require 'fileutils'

module Laborantin
  module Commands
    class Describe < Command
      describe "Gives a summary of what the current Laborantin project is"

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

      option(:analyses) do
        describe "comma separated list of analyses to describe"
        short "-a"
        long "--analyses=OPTIONAL"
        type Array
        default []
      end

      execute do
        ary = [[Environment, :environments], 
          [Scenario, :scenarii], [Analysis, :analyses]]
        ary.each do |klass, sym|
          puts "Available #{klass}"
          klass.all.each do |k|
            puts k.inspect if (opts[sym].empty? or (opts[sym].include?(k.name.duck_case)))
          end
        end
      end
    end
  end
end
