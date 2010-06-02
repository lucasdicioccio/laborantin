#runner/commands/analyze.rb

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
    class Analyze < Command
      describe "Runs the analyses"

      option(:analyses) do
        describe "comma separated list of analyses"
        short '-a' 
        long '--analyses=OPTIONAL' 
        default []
        type Array
      end

      execute do
        anae = if opts[:analyses].empty?
                 Analysis.all
               else
                 opts[:analyses].map!{|e| e.camelize}
                 Analysis.all.select{|e| opts[:analyses].include? e.name}
               end

        anae.each do |klass|
          puts "Analyzing: #{klass.name}"
          klass.new.analyze
        end
      end
    end
  end
end
