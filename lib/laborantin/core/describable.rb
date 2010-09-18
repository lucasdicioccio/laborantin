
module Laborantin
  module Metaprog
    module Describable
      # A description used for printing summary and debug purposes.
      attr_accessor :description

      alias :describe :description=
    end
  end
end
