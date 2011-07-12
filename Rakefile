require 'rubygems'
require 'rake/gempackagetask'

$LOAD_PATH.unshift('lib')
require 'lib/laborantin'

spec = Gem::Specification.new do |s|

        s.name = 'laborantin'
        s.rubyforge_project = 'laborantin'
        s.version = Laborantin::VERSION
        s.author = Laborantin::AUTHORS.first
        s.homepage = Laborantin::WEBSITE
        s.summary = "A measurement batch facilitator"
        s.email = "lucas.dicioccio<@nospam@>frihd.net"
        s.platform = Gem::Platform::RUBY

        s.files = [
          'README',
          'LICENSE', 
          'gpl-3.0.txt',
          'Rakefile', 
          'TODO', 
          'INFO',
          'bin/labor',
          'lib/laborantin.rb',
          'lib/laborantin/core/environment.rb',
          'lib/laborantin/core/parameter.rb',
          'lib/laborantin/core/parameter_hash.rb',
          'lib/laborantin/core/scenario.rb',
          'lib/laborantin/core/monkey_patches.rb',
          'lib/laborantin/core/analysis.rb',
          'lib/laborantin/core/command.rb',
          'lib/laborantin/core/datable.rb',
          'lib/laborantin/core/completeable.rb',
          'lib/laborantin/core/describable.rb',
          'lib/laborantin/core/hookable.rb',
          'lib/laborantin/core/configurable.rb',
          'lib/laborantin/core/multi_name.rb',
          'lib/laborantin/core/table.rb',
          'lib/laborantin/runner.rb',
          'lib/laborantin/runner/commands/complete.rb',
          'lib/laborantin/runner/commands/create.rb',
          'lib/laborantin/runner/commands/describe.rb',
          'lib/laborantin/runner/commands/run.rb',
          'lib/laborantin/runner/commands/analyze.rb',
          'lib/laborantin/runner/commands/load_classes.rb',
          'lib/laborantin/runner/commands/load_results.rb',
          'lib/laborantin/runner/commands/replay.rb',
          'lib/laborantin/runner/commands/find.rb',
          'lib/laborantin/runner/commands/scan.rb',
          'lib/laborantin/runner/commands/note.rb',
          'lib/laborantin/runner/commands/cleanup.rb',
          'lib/laborantin/runner/commands/rm.rb',
          'lib/laborantin/runner/commands/config.rb',
          'lib/laborantin/extra/commands/git.rb',
          'lib/laborantin/extra/commands/git/check.rb',
          'lib/laborantin/extra/commands/git/run.rb',
          'lib/laborantin/extra/vectorial_product.rb',
          'lib/laborantin/core/selector.rb',
          'lib/laborantin/core/dependencies.rb',
          'lib/laborantin/core/verifications.rb',
          'lib/laborantin/core/resolutions.rb',
          'lib/laborantin/core/dependency_solver.rb',
        ]

        s.require_path = 'lib'
        s.bindir = 'bin'
        s.executables = ['labor']
        s.has_rdoc = true
end

file 'INFO' => spec.files - ['INFO'] do
  print "trying to gather source revision for build ... "
  File.open('INFO', 'w') do |f|
    begin
      require 'git'
      g = Git.open('.')
      sha1 = g.revparse(g.current_branch)
      f.puts sha1
      puts "OK"
    rescue Exception => err
      puts "KO (not fatal)"
      f.puts "could not determine sha1 at packaging time"
      puts "#{err}"
    end
  end
end

Rake::GemPackageTask.new(spec) do |pkg|
        pkg.need_tar = true
end

task :gem => ["pkg/#{spec.name}-#{spec.version}.gem", 'INFO'] do
        puts "generated #{spec.version}"
end

