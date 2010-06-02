
module Laborantin
  module Commands
    module Git
      class Check < Laborantin::Command
        describe "Check if you're in a git repo, and master"
        plumbery!

        execute do
          unless Laborantin::Commands::Git.master_branch?
            puts "Cannot run unless you're in the master branch"
            exit
          end

          if Laborantin::Commands::Git.diff.stats[:total][:files] > 0
            puts "There are uncommited changes"
            exit
          end

          Laborantin::Commands::Git
        end
      end
    end
  end
end
