#runner/commands/note.rb

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
    class Note < Command
      describe "Appends a note to the BOOKNOTE file"
      execute do
        File.open('BOOKNOTE', 'a+') do |f|
          f.puts "#{Time.now}: #{args.join(' ')}"
        end
      end
    end
  end
end
