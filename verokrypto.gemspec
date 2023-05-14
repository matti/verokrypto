# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'verokrypto'
  spec.version = '0.0.2'
  spec.authors = ['Matti Paksula']
  spec.email = ['matti.paksula@iki.fi']

  spec.summary = 'verokrypto'
  spec.description = 'verokrypto'
  spec.homepage = 'https://github.com/matti/verokrypto'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'clamp', '1.3.2'
  spec.add_dependency 'money', '6.16.0'

  spec.add_dependency 'rubyXL', '3.4.22'

  spec.add_development_dependency 'rspec', '3.11.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rubocop', '1.27.0'
  spec.add_development_dependency 'rubocop-rake', '0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '2.9.0'
  spec.add_development_dependency 'solargraph', '0.44.3'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
