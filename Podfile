# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!
platform :ios, '15'

def shared_pods
  
    pod 'MaterialComponents/BottomSheet'
    pod 'MaterialComponents/TextControls+FilledTextAreas'
    pod 'MaterialComponents/TextControls+FilledTextFields'
    pod 'MaterialComponents/TextControls+OutlinedTextAreas'
    pod 'MaterialComponents/TextControls+OutlinedTextFields'
    pod 'MaterialComponents/AppBar'
    pod 'MaterialComponents/Tabs+TabBarView'
    pod 'MaterialComponents/Typography'
    pod 'MaterialComponents/Buttons'
    
    pod 'JJFloatingActionButton'
#    pod 'WalletConnectSwiftV2', '1.9.1'
    
#    pod 'Toast-Swift', '~> 4.0.0'
#    pod 'Floaty', '~> 4.1.0'
#    pod 'QRCode'
#    pod 'HPParallaxHeader'
#    pod 'IpfsApi'

    # replace keychainAccess with V2
    pod 'SwiftKeychainWrapper'
end

target 'Cosmostation' do
    shared_pods
end

target 'CosmostationDev' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15'
        if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
          target.build_configurations.each do |config|
              config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          end
        end
      end
    end
end
