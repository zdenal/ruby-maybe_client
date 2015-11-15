Gem::Specification.new do |spec|
  spec.name = "maybe_client"
  spec.version = "1.0.2"
  spec.files = ["lib/maybe_client.rb"]
  spec.authors = ["Jan Renra Gloser"]
  spec.email = ["jan.renra.gloser@gmail.com"]
  spec.summary = 'Wrapper for connection clients that handles outages without raising errors (and thus taking the application down). Ideal for making the application resilient in case of 3rd party failures (think your redis cache instance goes down)'
  spec.homepage = "https://github.com/renra/ruby-maybe_client"
  spec.license = "MIT"

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", '~> 0'
  spec.add_development_dependency "rspec", '3.4.0'
  spec.add_development_dependency "timecop", '0.8.0'
end
