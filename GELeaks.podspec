Pod::Spec.new do |s|

  s.name = "GELeaks"
  s.version = "0.1.1"
  s.summary = "Seamless leak detection in tests."

  s.description  = <<~END
    Make the existing tests checked for memory leaks.
  END

  s.homepage = "https://github.com/grigorye/GELeaks"
  s.license = 'MIT'

  s.author = { "Grigory Entin" => "grigory.entin@gmail.com" }

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.10'
  #s.watchos.deployment_target = "2.0"
  #s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/grigorye/GELeaks.git", :tag => "#{s.version}" }

  s.source_files = "GELeaks/*.{swift,h,m}"
  
  s.swift_version = '4.2'

  s.static_framework = true

  s.dependency 'FBAllocationTracker'
  s.framework = 'XCTest'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'GELeaksTests/**/*.swift'
  end

end
