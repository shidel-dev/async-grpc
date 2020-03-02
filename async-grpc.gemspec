
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "async/grpc/version"

Gem::Specification.new do |spec|
  spec.name          = "async-grpc"
  spec.version       = Async::Grpc::VERSION
  spec.authors       = ["shidel-dev"]
  spec.email         = ["joeshidel@gmail.com"]

  spec.summary       = "Performant async grpc server for ruby"
  spec.description   = "Performant async grpc server for ruby" 
  spec.homepage      = "https://github.com/shidel-dev/async-grpc"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/shidel-dev"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/shidel-dev/async-grpc"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "async-container", "0.14"
  spec.add_runtime_dependency "async-http"
  spec.add_runtime_dependency "google-protobuf"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "grpc"
  spec.add_development_dependency "async-rspec"
end
