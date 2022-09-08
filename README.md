## Installing MyUW iOS

Xcode 13.4.1 and Swift 5.6.1

Install Carthage (latest 0.38.0)
```
https://github.com/Carthage/Carthage
```


Clone this repository
```
$ git clone git@github.com:uw-it-aca/myuw-ios.git
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
$ carthage bootstrap --platform iOS --use-xcframeworks
```

Open the 'myuw-ios.xcodeproj' in Xcode.
