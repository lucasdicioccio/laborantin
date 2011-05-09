#laborantin.rb

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

[ 'laborantin/core/scenario',
  'laborantin/core/parameter',
  'laborantin/core/parameter_hash',
  'laborantin/core/environment',
  'laborantin/core/analysis',
  'laborantin/core/command',
  'laborantin/core/monkey_patches'
].each do |dep|
  require dep
end


module Laborantin
  VERSION = '0.0.21'
  AUTHORS = ['Lucas Di Cioccio']
  WEBSITE = 'http://dicioccio.fr/laborantin'
  LICENSE = 'GNU GPL version 3'
end
