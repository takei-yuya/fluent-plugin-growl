require 'rake'
require 'rake/testtask'
require 'rake/clean'

begin
	require 'jeweler'
	Jeweler::Tasks.new {|gemspec|
		gemspec.name = "fluent-plugin-growl"
		gemspec.summary = "Growl output plugin for Fluent Event Collector"
		gemspec.author = "TAKEI Yuya"
		gemspec.email = "takei.yuya@gmail.com"
		gemspec.homepage = "https://github.com/takei-yuya/fluent-plugin-growl"
		gemspec.has_rdoc = false
		gemspec.require_paths = ["lib"]
		gemspec.add_dependency "fluent", "~> 0.9.14"
		gemspec.add_dependency "ruby-growl", "~> 3.0"
		gemspec.test_files = Dir["test/**/*.rb"]
		gemspec.files = Dir["bin/**/*", "lib/**/*", "test/**/*.rb"] + %w[VERSION AUTHORS Rakefile]
		gemspec.executables = []
	}
	Jeweler::GemcutterTasks.new
rescue LoadError
	puts "Jeweler not available. Install it with: gem install jeweler"
end

Rake::TestTask.new(:test) {|t|
	t.test_files = Dir['test/*_test.rb']
	t.ruby_opts = ['-rubygems'] if defined? Gem
	t.ruby_opts << '-I.'
}

task :default => [:build]
