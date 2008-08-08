require 'rake/rdoctask'
require 'rake/testtask'

Rake::RDocTask.new do |rd|
	rd.main = "README"
	rd.rdoc_files.include("README", "lib/**/*.rb")
#	rd.template = 'jamis'
	rd.options = %w{--inline-source --line-numbers}
end

Rake::TestTask.new do |t|
	t.libs << 'test'
	t.test_files = FileList['test/*_test.rb']
	t.verbose = true
end

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |gem|
	gem.name     = "archive-tar"
	gem.version  = "0.9.0"
	gem.date     = "2008-08-04"
	gem.summary  = "An interface library for reading and writing UNIX tar files."

	gem.specification_version = 2 if gem.respond_to? :specification_version=

	gem.platform = Gem::Platform::RUBY
	gem.author   = "James R Hunt"
	gem.email    = "james@niftylogic.net"
	gem.homepage = "http://gems.niftylogic.net/activedirectory"
	gem.rubyforge_project = 'archive-tar'

	gem.files        = FileList["lib/**/*.rb"]
	gem.require_path = "lib"
	gem.has_rdoc     = true
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.gem_spec = spec
end
