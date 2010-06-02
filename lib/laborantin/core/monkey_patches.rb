#core/monkey_patchs.rb

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

# Some monkey patches on String. Will be moved later to a subclass.
class String
  # Returns a camelized version of a duck_case self
  #   'some_string'.camelize # => 'SomeString'
  def camelize
    self.split('_').map{|i| i.capitalize}.join('')
  end

  # Returns a duck cased version of camel-like self
  #   'SomeString'.duck_case # => 'some_string'
  def duck_case
    self.gsub(/([A-Z])/){|s| "_#{$1.downcase}"}.sub(/^_/,'')
  end
end
