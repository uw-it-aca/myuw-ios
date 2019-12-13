## Installing MyUW iOS

Xcode 8 and Swift 2.3

Install Carthage (latest 0.34)
```
https://github.com/Carthage/Carthage
```


Clone this repository
```
$ git clone https://github.com/uw-it-aca/myuw-ios
$ cd myuw-ios
$ git checkout develop
```

MyUW plist
```
$ cp myuw-ios/sample.myuw.plist myuw-ios/myuw.plist

 change the value for 'myuw_host' 

```

Bootstrap Carthage
```
$ carthage bootstrap --platform iOS
```

Open the 'myuw-ios.xcodeproj' in Xcode.
