Gem::Specification.new do |s|
  s.name        = 'db-migrate'
  s.version     = '0.2.0'
  s.licenses    = ['MIT']
  s.summary     = "Tool for managing and executing your database migrations."
  s.description = "#{s.summary} It supports multiple databases and multiple languages for writing migration scripts."
  s.authors     = ["Ivan Pusic"]
  s.email       = 'pusic007@gmail.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.homepage    = 'https://github.com/ivpusic/migrate'
  s.executables << 'migrate'

  # runtime deps
  s.add_runtime_dependency 'thor', ['0.19.1']
  s.add_runtime_dependency 'highline', ['1.7.8']
  s.add_runtime_dependency 'json', ['1.8.3']
  s.add_runtime_dependency 'parseconfig', ['1.0.6']
  s.add_runtime_dependency 'colorize', ['0.7.7']
  s.add_runtime_dependency 'terminal-table', ['1.5.2']
  s.add_runtime_dependency 'wannabe_bool', ['0.5.0']

  # dev deps
  s.add_development_dependency 'rspec', ['3.4.0']
  s.add_development_dependency 'pg', ['0.18.4']
  s.add_development_dependency 'mysql2', ['0.4.2']
end
