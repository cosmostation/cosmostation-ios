# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!
platform :ios, '13.5'

def shared_pods
    pod 'HDWalletKit', git: 'https://github.com/cosmostation/HDWallet.git', branch: 'cosmostation-develop'
    pod 'WalletConnect', git: 'https://github.com/cosmostation/wallet-connect-swift.git', branch: 'cosmostation-develop'
    pod 'web3swift', git: 'https://github.com/cosmostation/web3swift.git', branch: 'cosmostation-develop'
    
    pod 'MaterialComponents/BottomSheet'
    pod 'MaterialComponents/TextControls+FilledTextAreas'
    pod 'MaterialComponents/TextControls+FilledTextFields'
    pod 'MaterialComponents/TextControls+OutlinedTextAreas'
    pod 'MaterialComponents/TextControls+OutlinedTextFields'
    pod 'MaterialComponents/AppBar'
    pod 'MaterialComponents/Tabs+TabBarView'
    pod 'MaterialComponents/Typography'
    
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
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.5'
        if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
          target.build_configurations.each do |config|
              config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          end
        end
      end
    end
end
