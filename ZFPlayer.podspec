#
# Be sure to run `pod lib lint ZFPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

# https://www.jianshu.com/p/9eea3e7cb3a1 podsep 常用解析.

Pod::Spec.new do |s|
    s.name             = 'ZFPlayer'
    s.version          = '4.0.3'
    s.summary          = 'A good player made by renzifeng'
    s.homepage         = 'https://github.com/renzifeng/ZFPlayer'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'renzifeng' => 'zifeng1300@gmail.com' }
    s.source           = { :git => 'https://github.com/renzifeng/ZFPlayer.git', :tag => s.version.to_s }
    s.social_media_url = 'http://weibo.com/zifeng1300'
    s.ios.deployment_target = '8.0'
    s.requires_arc = true
    s.static_framework = true
    # Example 的 Pod, 使用了 All, 但是这里指定的是 Core. 应该在 Example 里面修改的.
    s.default_subspec = 'Core'
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    
    s.subspec 'Core' do |core|
        core.source_files = 'ZFPlayer/Classes/Core/**/*'
        # //在这个属性中声明过的.h文件能够使用<>方法联想调用（这个是可选属性）
        core.public_header_files = 'ZFPlayer/Classes/Core/**/*.h'
        # //需要用到的frameworks，不需要加.frameworks后缀。（这个没有用到也可以不填）
        # **/*表示Classes目录及其子目录下所有文件
        core.frameworks = 'UIKit', 'MediaPlayer', 'AVFoundation'
    end
    
    s.subspec 'ControlView' do |controlView|
        controlView.source_files = 'ZFPlayer/Classes/ControlView/**/*.{h,m}'
        controlView.public_header_files = 'ZFPlayer/Classes/ControlView/**/*.h'
        controlView.resource = 'ZFPlayer/Classes/ControlView/ZFPlayer.bundle'
        controlView.dependency 'ZFPlayer/Core'
    end
    
    s.subspec 'AVPlayer' do |avPlayer|
        avPlayer.source_files = 'ZFPlayer/Classes/AVPlayer/**/*.{h,m}'
        avPlayer.public_header_files = 'ZFPlayer/Classes/AVPlayer/**/*.h'
        avPlayer.dependency 'ZFPlayer/Core'
    end
    
    s.subspec 'ijkplayer' do |ijkplayer|
        ijkplayer.source_files = 'ZFPlayer/Classes/ijkplayer/*.{h,m}'
        ijkplayer.public_header_files = 'ZFPlayer/Classes/ijkplayer/*.h'
        ijkplayer.dependency 'ZFPlayer/Core'
        ijkplayer.dependency 'IJKMediaFramework'
    end
    
    s.subspec 'All' do |ss|
        ss.dependency 'ZFPlayer/Core'
        ss.dependency 'ZFPlayer/ControlView'
        ss.dependency 'ZFPlayer/AVPlayer'
        ss.dependency 'ZFPlayer/ijkplayer'
    end
    
end
