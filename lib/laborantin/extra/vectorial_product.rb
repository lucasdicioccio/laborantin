
module Laborantin
  module VectorialProduct
    def vectors
      @vectors ||= {}
    end

    def vector_file(sym)
      blk = lambda {|f| yield f}
      if sym == :__raw__
        raw_result_file &blk
      else
        product_file(sym, &blk)
      end
    end

    def vector(sym=:__raw__)
      vectors[sym] ||= read_vector(sym)
    end

    def read_vector(sym)
      vals = []
      vector_file(sym) do |file|
        file.each_line do |line|
          vals << line.chomp.to_f
        end
      end
      vals
    end
  end
end
