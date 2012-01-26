
module Laborantin
  module Commands
    module Show
      class Exports < Command
        describe "list the exports"

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

        #TODO: mime-type

        execute do
          results = Laborantin::Commands::LoadResults.new.run([],opts)
          results[:scii].each do |sc|
            sc.class.products.each do |name|
              sc.exports.each_pair do |k,v|
                path = sc.product_path(k, true)
                puts "#{path} (#{v})"
              end
            end
          end
        end

      end
    end
  end
end
