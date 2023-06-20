# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!
platform :ios, '13.5'

def shared_pods
    pod 'SwiftyJSON', '~> 4.3'
    pod 'HDWalletKit', git: 'https://github.com/cosmostation/HDWallet.git', branch: 'cosmostation-develop'
    pod 'WalletConnect', git: 'https://github.com/cosmostation/wallet-connect-swift.git', branch: 'cosmostation-develop'
    pod 'web3swift', git: 'https://github.com/cosmostation/web3swift.git', branch: 'cosmostation-develop'
    pod 'AlamofireImage', '~> 3.3'
    pod 'SQLite.swift', '~> 0.11.5'
    pod 'SwiftKeychainWrapper'
    pod 'Toast-Swift', '~> 4.0.0'
    pod 'Floaty', '~> 4.1.0'
    pod 'QRCode'
    pod 'Firebase/Core', '8.1'
    pod 'Firebase/Messaging', '8.1'
    pod 'HPParallaxHeader'
    pod 'IpfsApi'
    pod 'WalletConnectSwiftV2', '1.3.0'
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
