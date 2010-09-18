#core/parameter.rb

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

  # A ParameterRange instance is more or less a wrapper over an Array of allowed values.
  class ParameterRange

    # The name of the parameter (should be unique in a Scenario's parameters)
    # Usually a symbol.
    attr_accessor :name

    # A description used for printing summary and debug purposes. Will be 
    # used to create .tex report in the future.
    attr_accessor :description

    # initialize a new instance with the desired name
    def initialize(name)
      @name = name
      @values = []
      @description = ''
    end

    # Sets the allowed values. Currently only supports Array like. 
    # It is planned to support Iterable, but deterministic ones only.
    def values(*args)
      @values = args.flatten unless args.empty?
      @values
    end

    # Iterates on allowed values for this parameter.
    def each
      @values.each do |v| 
        yield v
      end
    end

    # Sets the description string that will be used in debugs, reports etc.
    def describe(str)
      @description = str
    end
  end
end
