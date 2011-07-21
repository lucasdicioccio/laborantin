module Laborantin
  class Table
    attr_reader :name, :struct, :path
    attr_accessor :separator, :comment, :header
    def initialize(name, struct=nil, path=nil)
      @name = name
      @struct = struct
      @path = path
      @separator = ' '
      @comment = '#'
      @heaer = nil
      yield self if block_given?
    end

    def fields
      struct.members.map(&:to_s)
    end

    def header
      @header || [comment, fields].flatten.join(separator).strip
    end

    class Filler < Proc
      alias :<< :call
    end

    def fill(&blk)
      File.open(path, 'w') do |f|
        f.puts header if struct
        filler = Filler.new do |val|
          f.puts dump(val)
        end
        blk.call(filler)
      end
    end

    def dump(obj, check=true)
      strings = obj.to_a.map(&:to_s)
      if check
        if strings.find{|s| s.include?(separator)}
          raise ArgumentError, "cannot unambiguously dump a value with the separator"
        end
      end
      line = strings.join(separator)
      if check
        if line.start_with?(comment) and (not comment.empty?)
          raise ArgumentError, "line starting with comment\n#{line}" 
        end
        expected = struct.members.size
        got = line.split(separator).size
        if got != expected
          raise ArgumentError, "ambiguous line: #{got} fields instead of #{expected} in \n#{line}"
        end
      end
      line
    end

    def read(hash={})
      if block_given?
        File.open(path) do |f|
          f.each_line do |l|
            next if l.start_with?(comment)
            strings = l.chomp.split(separator)
            pairs = [struct.members, strings].transpose

            atoms = pairs.map do |sym, val|
              int = hash[sym]
              if int
                val.send(int)
              else
                val
              end
            end

            yield struct.new(*atoms)
          end
        end
      else
        Enumerator.new(self, :read, hash)
      end
    end

  end
end
