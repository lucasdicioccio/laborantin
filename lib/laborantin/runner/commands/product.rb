
module Laborantin
  module Commands
    module Show
      class Products < Command
        describe "shows the products path"

        option(:scenarii) do
          describe "comma separated list of scenarios to describe"
          short "-s"
          long "--scenarii=OPTIONAL"
          type Array
          default []
        end

        option(:environments) do
          describe "comma separated list of environments to describe"
          short "-e"
          long "--envs=OPTIONAL"
          type Array
          default []
        end

        option(:parameters) do
          describe "filter for parameters (a hash as Ruby syntax code)"
          short '-p'
          long '--parameters=OPTIONAL'
          type String
          default ''
        end

        execute do
          results = Laborantin::Commands::LoadResults.new.run([],opts)
          results[:scii].each do |sc|
            sc.class.products.each do |name|
              path = sc.product_path(name.to_s)
              puts path
            end
          end
        end

      end
    end
  end
end
