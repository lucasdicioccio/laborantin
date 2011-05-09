
module Laborantin
  module Metaprog
    module Completeable
      # A block to propose completion on this option
      attr_reader :completion_block

      # Stores the block argument in the completion_block, usage is for DSLs
      def complete(&blk)
        @completion_block = blk
      end


      # Provides completion facility for comma-separated lists of args, and returns the propositions
      # - removes items already in list
      # - prepends commas for items not already in list
      def completion_propositions_iterating_on(cmd, list)
        envs_on_cli = cmd.split.last.split(',').reject{|s| s.start_with?('-')}
        last_env_on_cli = envs_on_cli.last unless cmd.end_with?(',')
        last_env_on_cli ||= ''
        complete_envs_on_cli = envs_on_cli - [last_env_on_cli]

        list = list.select{|str| str.start_with?(last_env_on_cli)}
        candidate_envs = list - envs_on_cli
        candidate_envs.map{|str| (complete_envs_on_cli + [str]).join(',') } 
      end

    end
  end
end
