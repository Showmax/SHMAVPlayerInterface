Pod::Spec.new do |s|
  s.name             = 'SHMAVPlayerInterface'
  s.version          = '1.1.0'
  s.summary          = 'SHMAVPlayerInterface provides an easy-to-use interface for AVPlayer and AVPlayerItem. You can replace KVO, CMTime, media groups, and other unfriendly APIs.'

  s.description      = <<-DESC

SHMAVPlayerInterface provides an easy-to-use interface for AVPlayer and AVPlayerItem. You can replace KVO, CMTime, media groups, and other unfriendly APIs.

The SHMAVPlayerInterface library provides a reactive API to observe important properties. SHMAVPlayerInterface also gives you a wrapper around AVPlayer to handle basic actions like play/pause and subtitles changes. You still retain full control over your AVPlayer.

                       DESC

  s.homepage         = 'https://github.com/ShowMax/SHMAVPlayerInterface'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Showmax' => 'ios@showmax.com' }
  s.source           = { :git => 'https://github.com/ShowMax/SHMAVPlayerInterface.git', :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/showmaxdevs'

  s.platforms = { :ios => "9.0", :tvos => "10.0" }
  s.frameworks = 'AVFoundation'

  s.dependency 'RxSwift', '~> 3.5.0'
  s.dependency 'RxCocoa', '~> 3.5.0'

  s.source_files = ['Source/*.swift']
end
