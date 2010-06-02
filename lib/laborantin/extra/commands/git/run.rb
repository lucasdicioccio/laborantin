
module Laborantin
  module Commands
    module Git
      class Run < Laborantin::Command

        describe "like run, with git integration before"

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

        option(:analyze) do
          describe "set this flag to analyze as you run"
          short '-a'
          long '--analyze'
          default false
        end

        option(:force) do
          describe "set this flag to prevent git branch verification"
          short '-f'
          long '--force'
          default false
        end

        execute do

          Laborantin::Commands::Git::Check.new().run unless opts[:force]

          git =  Laborantin::Commands::Git

          puts "Running with #{git.branch} #{git.commit_id}"

          # Parameters parsing
          params = eval(opts[:parameters]) unless opts[:parameters].empty?
          params.each_key{|k| params[k] = [params[k]].flatten} if params

          # Environments and Scenarii filtering
          envs = if opts[:environments].empty?
                   Laborantin::Environment.all
                 else
                   opts[:environments].map!{|e| e.camelize}
                   Laborantin::Environment.all.select{|e| opts[:environments].include? e.name}
                 end

          scii = if opts[:scenarii].empty?
                   Laborantin::Scenario.all
                 else
                   opts[:scenarii].map!{|e| e.camelize}
                   Laborantin::Scenario.all.select{|e| opts[:scenarii].include? e.name}
                 end

          # Actual run of experiments
          envs.each do |eklass|
            env = eklass.new
            env.config[:git] = {:commit => git.commit_id}
            #TODO: store revision
            if env.valid?
              env.prepare!
              env.log "Running matching scenarii", :info #TODO: pass the logging+running in the env
              scii.each do |sklass|
                sklass.parameters.merge! params if params
                env.log sklass.parameters.inspect
                sklass.parameters.each_config do |cfg|
                  sc = sklass.new(env, cfg)
                  sc.prepare!
                  sc.perform!
                  sc.analyze! if opts[:analyze]
                end
              end
              env.teardown!
              env.log "Scenarii performed", :info
            end
          end
        end
      end
    end
  end
end
