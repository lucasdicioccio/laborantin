#runner/commands/cleanup.rb

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
    class Cleanup < Command
      plumbery!
      describe "Removes the result directories of the environments without scenarios"
      execute do
        results = Laborantin::Commands::LoadResults.new.run([],opts)
        results[:envs].each do |env|
          scii = env.populate
          if scii.empty?
            FileUtils.rm_rf(env.rundir, :verbose => true)
          end
        end
      end
    end
  end
end
