task :test do
  $:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'test'))

  Dir['test/**/*_test.rb'].each do |file|
    load file  unless file =~ /^-/
  end
end

task :default => :test
