
module Laborantin
  module Commands
    class Clean < Command
      describe "cleans the products (i.e., post-processed files declared as products) of the matching scenarios and environments"

      option(:scenarii) do
        describe "comma separated list of scenarios to describe"
        short "-s"
        long "--scenarii=OPTIONAL"
        type Array
        default []
        complete do |cmd|
          completion_propositions_iterating_on(cmd, Laborantin::Scenario.all.map(&:cli_name))
        end
      end

      option(:environments) do
        describe "comma separated list of environments to describe"
        short "-e"
        long "--envs=OPTIONAL"
        type Array
        default []
        complete do |cmd|
          completion_propositions_iterating_on(cmd, Laborantin::Environment.all.map(&:cli_name))
        end
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
            FileUtils.rm_f(path, :verbose => true)
          end
        end
      end

    end
  end
end
