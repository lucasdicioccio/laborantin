#core/parameter_hash.rb

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
  # A kind of Hash that can yields all possible configuration recursively.
  # It should contains ParameterRange like definitions objects.
  class ParameterHash < Hash
    # Recursively yields all the possible configurations of parameters (a new hash).
    # No order is supported on the recursion, and it is not planned to.
    def each_config(remaining=self.keys, cfg={}, &blk)
      key = remaining.pop
      if key
        self[key].each do |val|
          cfg[key] = val
          each_config(remaining.dup, cfg, &blk)
        end
      else
        yield cfg
      end
    end

    def to_s
      keys.inject(''){|s,k| s + "\t- #{k}: #{self[k]}.\n"}
    end
  end
end
