
module Laborantin
  # Poor man's dependency greedy and recursive algorithm raises an error after
  # two consecutive calls with the same previoulsy_wrong dependencies list
  # we rely on the implementer to not create dependency loops.
  # The whole dependency design is extremely wasteful, but it works.
  module DependencySolver
    def resolve_dependencies(obj, previously_wrong=[])
      valid, wrong = obj.class.dependencies.partition do |dep|
        dep.valid?(obj)
      end

      if wrong.empty?
        puts "all dependencies met"
      else
        puts "unmet dependencies: #{wrong.map(&:name).join(' ')}"
        if previously_wrong == wrong
          raise RuntimeError, "already tried resolving these dependencies"
        else
          wrong.each do |dep|
            # Since iterating changes the status of the dependency, we may want to re-test if a dep is valid or not.
            # the assumption is that resolving a dep costs more than testing if it's valid or not
            dep.verifications.each{|v| v.resolve!(obj)} unless dep.valid?(obj) 
          end
          resolve_dependencies(obj, wrong)
        end
      end
    end
  end
end
