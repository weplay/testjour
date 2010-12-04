Gem::Specification.new do |s|
  s.name         = "testjour"
  s.version      = "0.3.4"
  s.author       = "Bryan Helmkamp"
  s.email        = "bryan" + "@" + "brynary.com"
  s.homepage     = "http://github.com/brynary/testjour"
  s.summary      = "Distributed test running with autodiscovery via Bonjour (for Cucumber first)"
  s.description  = s.summary
  s.executables  = "testjour"
  s.files        = %w[History.txt MIT-LICENSE.txt README.rdoc Rakefile] + Dir["bin/*"] + Dir["lib/**/*"] + Dir["vendor/**/*"]
  s.add_dependency('systemu')
  s.add_dependency('rspec', '1.2.7')
  s.add_dependency('cucumber', '>= 0.6.1')
  s.add_dependency('redis')
  s.add_dependency('daemons')
end