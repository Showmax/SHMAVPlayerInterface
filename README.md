# SHMTableView

[![Swift][swift-badge]][swift-url]
[![Platform][platform-badge]][platform-url]
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

**SHMAVPlayerInterface** provides easy-to-use interface for `AVPlayer` and `AVPlayerItem`. You can forget on `KVO`, `CMTime`, media groups and other not so easy-to-use APIs. This library provides reactive API to observe important properties. And you also have wrapper around `AVPlayer` to handle basic actions like play/pause and subtitles changes. And still you have full control over your `AVPlayer`.

`SHMAVPlayerInterface` is using [RxSwift](https://github.com/ReactiveX/RxSwift) and [RxCocoa](https://github.com/ReactiveX/RxSwift) libraries. If you are not familiar with reactive programming you should look at them first.

## Installation

`SHMAVPlayerInterface` is available through [CocoaPods](http://cocoapods.org).

Add the following line to your `Podfile`

```ruby
pod 'SHMAVPlayerInterface'
```

Install dependencies

```bash
pod install
```

## Getting Started

1) Include `SHMAVPlayerInterface` into your swift file

```swift
import SHMAVPlayerInterface
```

2a) Create `SHMAVPlayerInterface` object and start using `AVPlayer`

```swift
let player: AVPlayer = ...
let playerInterface = SHMAVPlayerInterface(player: player)

playerInterface.play()

let subtitles = playerInterface.availableSubtitles
...
```

2b) Or start observing `AVPlayer` (or `AVPlayerItem`) properties via reactive API.

```swift
let player: AVPlayer = ...

// Get update about playback position every second on main thread.
playerInterface.player.rx.playbackPosition(updateInterval: 1.0, updateQueue: nil)
  .subscribe(
      onNext: { position in

          print("Playback position: \(position)")
      }
  )
  .disposed(by: bag)
```

**IMPORTANT: If you use reactive extension for `AVPlayer` or `AVPlayerItem` then you must dispose your `DisposeBag` before you destroy `AVPlayer` or `AVPlayerItem`. If you don't do it then application will crash.**

## Documentation

Main source of documentation is code. Every public API is commented.

## Example code

This repository contains real world example how to use this library. This example use `AVPlayerViewController` with custom UI on `iOS` and with default UI for `tvOS`.

To run the example project, clone the repo, and run `pod install` from the Example directory.

```
cd libs/SHMAVPlayerInterface/Example
pod install
open SHMAVPlayerInterface.xcworkspace
```

## Authors

Showmax is an internet-based subscription video on demand service supplying an extensive catalogue of TV shows and movies. By leveraging relationships with major production studios from across the globe, Showmax delivers both world-class international content as well as the best of specialised local content. Showmax is accessible across a wide range of devices from smart TVs and computers to smartphones and tablets.

You can follow us at https://tech.showmax.com and/or https://twitter.com/ShowmaxDevs .

## Status

This code is exactly one running in our production app. We are using the same pod as you see here. PRs are welcome.

## License

`SHMAVPlayerInterface` is available under the Apache license. See the `LICENSE` file for more info.

[swift-badge]: https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platforms-iOS%20+%20tvOS-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[travis-badge]: https://travis-ci.org/showmax/shmtableview.svg?branch=master
[travis-url]: https://travis-ci.org/showmax/shmtableview
