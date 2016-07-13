Pod::Spec.new do |spec|
  spec.name = "NPOKit"
  spec.version = "1.0.0"
  spec.summary = "NPOKit framework.";
  spec.homepage = "https://github.com/4np/UitzendingGemist"
  spec.license = { type: 'APACHE', file: 'LICENSE' }
  spec.authors = { "Jeroen Wesbeek" => 'github@osx.eu' }

  spec.platform = :tvos, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/4np/UitzendingGemist.git", submodules: true }
  spec.source_files = "NPOKit/**/*.{h,swift}"

  spec.dependency 'CocoaLumberjack/Swift'
  spec.dependency 'Alamofire', '~> 3.4'
  spec.dependency 'Genome', '~> 2.0.0'
end
