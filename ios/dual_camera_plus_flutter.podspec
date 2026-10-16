Pod::Spec.new do |s|
  s.name             = 'dual_camera_plus_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Simultaneous dual camera recording with focus and exposure hardware control.'
  s.description      = <<-DESC
Simultaneous front + back camera recording and photo capture, composited on the
GPU (Metal) into a single video/photo via AVCaptureMultiCamSession with hardware focus and exposure control.
                       DESC
  s.homepage         = 'https://github.com/hoangsang17th/dual_camera_plus_flutter'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Pham Hoang Sang' => 'phsang49@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
