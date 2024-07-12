platform :ios, '17.5'

target 'ToDo' do
  pod 'SwiftLint'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.5'
  end
 end
end
