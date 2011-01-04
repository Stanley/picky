# Specs.
#
require 'spec'
require 'spec/rake/spectask'

spec_root = File.expand_path '../../spec', __FILE__

desc "Run specs."
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{File.join(spec_root, 'spec.opts')}\""]
  t.spec_files = FileList[File.join(spec_root, '**', '*_spec.rb')]
end

task :simplecov do
  ENV['COV'] = 'yes'
end

desc "Run specs with coverage."
task :cov do
  Rake::Task['simplecov'].invoke
  Rake::Task['spec'].invoke
end