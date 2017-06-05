# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Weego 2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Fabric'
  pod 'Crashlytics'

  # Pods for Weego
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'

  # pod 'Firebase/Invites'
  # pod 'Firebase/Storage'
 

  # Only pull in Phone Auth login features
  # https://github.com/firebase/FirebaseUI-iOS
  # Temp for testing
  pod 'FirebaseUI/Phone', '~> 4.0'

  target 'Weego 2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Weego 2UITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
