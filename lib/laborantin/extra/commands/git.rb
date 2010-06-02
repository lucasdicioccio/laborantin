
require 'git'
require 'laborantin/extra/commands/git/check'
require 'laborantin/extra/commands/git/run'

module Laborantin
  module Commands
    # A Git set of Commands, to enable it, pass to true the :extra :git flag.
    module Git

      HERE = '.'

      # Just get a git object for current working dir (implementation is crappy, but will be refined later)
      def self.git
        @g ||= Object::Git.open(HERE)
      end

      # Get the current working directory branch.
      def self.branch
        self.git.current_branch
      end

      # Get the commit-id (long sha1) where current branch is pointing to.
      def self.commit_id
        self.git.revparse(branch)
      end

      # Returns true if current working dir is master.
      def self.master_branch?
        'master' == branch
      end

      # Returns the Diff between current directory and the HEAD of current
      # branch.
      def self.diff
        git.diff(commit_id, HERE)
      end
    end
  end
end
