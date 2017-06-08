Pod::Spec.new do |s|
  s.name             = 'SHMAVPlayerInterface'
  s.version          = '1.0.0'
  s.summary          = 'SHMAVPlayerInterface provides easy-to-use interface for AVPlayer. You can forget on KVO, CMTime, media groups and other not so easy-to-use APIs.'

  s.description      = <<-DESC


SHMAVPlayerInterface provides easy-to-use interface for AVPlayer. You can forget on KVO, CMTime, media groups and other not so easy-to-use APIs. 
You have now reactive API to observe important properties. And you also have wrapper around AVPlayer to handle basic actions like play/pause and subtitles changes.

And still you have full control over your AVPlayer.

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
