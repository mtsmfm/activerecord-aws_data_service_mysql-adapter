
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "activerecord-aws_data_service_mysql-adapter"
  spec.version       = "0.1.0"
  spec.authors       = ["Fumiaki MATSUSHIMA"]
  spec.email         = ["mtsmfm@gmail.com"]

  spec.summary       = %q{An Aurora Serverless ActiveRecord adapter}
  spec.description   = %q{An Aurora Serverless ActiveRecord adapter}
  spec.homepage      = "https://github.com/mtsmfm/activerecord-aws_data_service_mysql-adapter"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mtsmfm/activerecord-aws_data_service_mysql-adapter"
    spec.metadata["changelog_uri"] = "https://github.com/mtsmfm/activerecord-aws_data_service_mysql-adapter"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|.devcontainer)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", [">= 6.0.0.rc2"]
  spec.add_runtime_dependency "aws-sdk-rdsdataservice", [">= 1.10.0"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
