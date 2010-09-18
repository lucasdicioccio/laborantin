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

require 'laborantin/core/describable'

module Laborantin

  # A ParameterRange instance is more or less a wrapper over an Array of allowed values.
  class ParameterRange

    include Metaprog::Describable

    # The name of the parameter (should be unique in a Scenario's parameters)
    # Usually a symbol.
    attr_accessor :name

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

    def to_s
      "#{values.inspect}\n\t\t#{@description}"
    end
  end
end
