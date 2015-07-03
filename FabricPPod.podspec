
Pod::Spec.new do |s|
  s.name             = "FabricPPod"
  s.version          = "0.0.1"
  s.summary          = "A short description of FabricPPod."
  s.homepage         = "https://github.com/kwongius/FabricPPod-test"
  s.license          = 'MIT'
  s.author           = { "Kevin Wong" => "snarpel@gmail.com" }
  s.source           = { :git => "https://github.com/kwongius/FabricPPod-test.git" }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.subspec 'Fabric' do |ss|
    ss.vendored_frameworks = 'ios_kits/Fabric.framework'
  end

  s.subspec 'Crashlytics' do |ss|
    ss.vendored_frameworks = 'ios_kits/Crashlytics.framework'
    ss.dependency s.name + '/Fabric'
    ss.libraries = "c++", "z"
  end

end
