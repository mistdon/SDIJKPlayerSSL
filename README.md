# SDIJKPlayerSSL

[![CI Status](http://img.shields.io/travis/momo13014/SDIJKPlayerSSL.svg?style=flat)](https://travis-ci.org/momo13014/SDIJKPlayerSSL)
[![Version](https://img.shields.io/cocoapods/v/SDIJKPlayerSSL.svg?style=flat)](http://cocoapods.org/pods/SDIJKPlayerSSL)
[![License](https://img.shields.io/cocoapods/l/SDIJKPlayerSSL.svg?style=flat)](http://cocoapods.org/pods/SDIJKPlayerSSL)
[![Platform](https://img.shields.io/cocoapods/p/SDIJKPlayerSSL.svg?style=flat)](http://cocoapods.org/pods/SDIJKPlayerSSL)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SDIJKPlayerSSL is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/momo13014/Specs'

pod 'SDIJKPlayerSSL'
```

## 构建过程

以下几步需要改动，其他步骤和编译IJKMediaFramework是一样的


```bash

1. ./init-ios-openssl.sh    //SSL必需, 如果是只播放http的话,可以忽略这一步

2. ./init-ios.sh

then cd ios

3.1. ./compile-openssl.sh clean

3.2. ./compile-ffmpeg.sh clean

4.1. ./compile-openssl.sh all

4.2. ./compile-ffmpeg.sh all
```

合并的教程： [带你封装IJKPlayer直播框架](http://www.jianshu.com/p/a91751b0262c)
其中，在合并的时候，关于合并的命令，cd 到Products路径下

```
lipo -create Release-iphoneos/IJKMediaFrameworkWithSSL.framework/IJKMediaFrameworkWithSSL Release-iphonesimulator/IJKMediaFrameworkWithSSL.framework/IJKMediaFrameworkWithSSL -output IJKMediaFrameworkWithSSL

```

生成后替换成需要的framwrok

## Links

[ijkplayer增加https协议支持](http://blog.csdn.net/linchaolong/article/details/52805666)

[IJKPlayer爬坑记](http://www.jianshu.com/p/2e5b9a4f3ce4)

## 常见问题

1.  [iOS11 有声音无画面](https://github.com/Bilibili/ijkplayer/issues/3643)
    现代码里面已经做了修复
    
## 测试链接
>  `"https://media.w3.org/2010/05/sintel/trailer.mp4"`

>  `"http://mvvideo2.meitudata.com/5785a7e3e6a1b824.mp4?k=18455aa3fed468886b9df95eed493f0b&t=59e41659"`

>  `"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"`


## Author

momo13014, shendong13014@gmail.com

## License

SDIJKPlayerSSL is available under the MIT license. See the LICENSE file for more info.
