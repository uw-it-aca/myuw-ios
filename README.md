## Installing MyUW iOS

Requirements
- Xcode 27 (iOS 27 SDK)
- Minimum deployment target: iOS 15.0

## Dependencies

Dependencies are managed with Swift Package Manager (SPM). No separate install step is needed; Xcode downloads them the first time the project is opened.

| Package | Version |
|---|---|
| [AppAuth-iOS](https://github.com/openid/AppAuth-iOS) | 3.0.x (up to next major) |

Exact versions are pinned in `myuw-ios.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`. Commit this file whenever it changes.

Update dependencies: in Xcode, choose File > Packages > Update to Latest Package Versions, then commit the updated `Package.resolved`.

Resolve dependencies from the command line (e.g. CI):
```
$ xcodebuild -resolvePackageDependencies -project myuw-ios.xcodeproj
```

If packages fail to resolve, choose File > Packages > Reset Package Caches.

## Setup

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

Open the 'myuw-ios.xcodeproj' in Xcode.

## Tests and code coverage

Code coverage is enabled in the shared `MyUW` scheme and is collected for the app target (`MyUW.app`) only.

In Xcode, run tests with Product > Test (⌘U), then open the Report navigator (⌘9) and select the Coverage report.

From the command line:
```
$ xcodebuild test -project myuw-ios.xcodeproj -scheme MyUW \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    -resultBundlePath TestResults.xcresult
$ xcrun xccov view --report --only-targets TestResults.xcresult
```
