
module Laborantin
  module Metaprog
    module Datable
      attr_accessor :date

      # Format the date of as a string (rounded at 1second).
      def date_str
        date.strftime("%Y-%h-%d_%H-%M-%S")
      end
    end
  end
end
