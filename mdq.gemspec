# frozen_string_literal: true

require_relative 'lib/mdq/version'

Gem::Specification.new do |spec|
  spec.name = 'mdq'
  spec.version = Mdq::VERSION
  spec.authors = ['arthur87']
  spec.email = ['arthur87@users.noreply.github.com']
  spec.licenses = ['MIT']

  spec.summary = 'mdq is a command line tool for displaying information about Android and Apple devices.'
  spec.description = 'mdq is a command line tool for displaying information about Android and Apple devices.'
  spec.homepage = 'https://github.com/arthur87/mdq'
  spec.required_ruby_version = '>= 3.0.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/arthur87/mdq'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency 'rubocop'
  spec.add_dependency 'activerecord'
  spec.add_dependency 'sqlite3'
  spec.add_dependency 'thor'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
