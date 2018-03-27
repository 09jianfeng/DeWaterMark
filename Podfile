#inhibit_all_warnings!
platform :ios, '8.0'

#xcodeproj 'SimpleCapture'

source 'https://github.com/CocoaPods/Specs.git'

target 'DeWaterMark' do
pod 'CocoaLumberjack', '3.1.0'
pod 'Masonry', '1.0.2'
pod 'GCDWebServer/WebDAV', '~> 3.0'
pod 'KVOController', '1.2.0'
pod 'NSLogger', '1.8.3'
pod 'MBProgressHUD', '1.1.0'
pod 'MMDrawerController', '~> 0.5.7'
pod 'AFNetworking', '3.1.0'
pod 'mob_sharesdk/ShareSDKPlatforms/QQ', '4.1.0'
pod 'mob_sharesdk/ShareSDKPlatforms/WeChat', '4.1.0'
# UI模块(非必须，需要用到ShareSDK提供的分享菜单栏和分享编辑页面需要以下1行)
pod 'mob_sharesdk/ShareSDKUI'
pod 'mob_sharesdk/ShareSDKExtension'
pod 'SDWebImage', '4.2.2'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                        config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
            end
    end
end
