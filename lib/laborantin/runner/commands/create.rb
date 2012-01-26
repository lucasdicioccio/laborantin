#runner/commands/create.rb

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

require	'fileutils'
require 'find'
require 'erb'

module Laborantin
  module Commands
    class Create < Command
      describe "prepares a directory structure for Laborantin"

      option(:force) do
        describe 'force overwrite, use with care'
        short '-f'
        long '--force'
        default false
      end

      execute do
        #Build Tree Structure
        dirs_to_build = []

        rootdir = File.join('.', (args.first) || '')

        dirs_to_build << rootdir

        %w{analyses commands lib config environments reports results scripts scenarii data}.each do |dirname|
          dirs_to_build << File.join(rootdir, dirname)
        end

        dirs_to_build.each do |path|
          FileUtils::Verbose.mkdir_p(path)
        end

        #TODO: create a README, a NOTEBOOK
      end
    end
  end
end

