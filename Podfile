# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

def shared_pods
    pod 'SwiftyJSON', '~> 4.3'
    pod 'HDWalletKit', :git => 'https://github.com/cosmostation/HDWallet.git', branch: 'develop'
    pod 'Starscream', '~> 3.1.0'
    pod 'WalletConnect', git: 'https://github.com/cosmostation/wallet-connect-swift.git', branch: 'master'
    pod 'AlamofireImage', '~> 3.3'
    pod 'SQLite.swift', '~> 0.11.5'
    pod 'SwiftKeychainWrapper'
    pod 'Toast-Swift', '~> 4.0.0'
    pod 'Floaty', '~> 4.1.0'
    pod 'DropDown'
    pod 'QRCode'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'NotificationBannerSwift', '2.0.1'
    pod 'gRPC-Swift', '~> 1.0.0'
    pod 'gRPC-Swift-Plugins'
    pod 'HPParallaxHeader'
    pod 'IpfsApi'
    pod 'web3swift', git: 'https://github.com/cosmostation/web3swift.git', branch: 'cosmostation-evmos'
end

target 'Cosmostation' do
    shared_pods
end

target 'CosmostationDev' do
    shared_pods
end
