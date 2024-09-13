# mirrortask

## object image


* blue channel: boundaries
* green channel: inside object
* alpha channel: blue|green
* height=width
* high resolution (will be downscaled within the app)

## results

### drawing

list of list of tuples:
* all: list of lines
* lines: list of samples
* sample: tuple (x,y,t) with
  * x,y are coordinates in result image
  * t is timestamp in ms

### image

* blue channel: boundaries
* green channel: inside object
* red channel: drawing
* alpha channel: blue|green|red
* height=width

## TODO

- use 7 digit ID
- project name + wave

- test max upload size / big trajectories
- also save to local DB?
- save autocomplete info in results?


## locally saved files

### iOS
"To make the directory available to the user you need to open the Xcode project under 'your_app/ios/Runner.xcworkspace'. Then open the Info.plist file in the Runner directory and add two rows with the key UIFileSharingEnabled and LSSupportsOpeningDocumentsInPlace. Set the value of both keys to YES.
If you now open the Files app and click on 'On My iPhone' you should see a folder with the name of your application."

https://stackoverflow.com/questions/55220612/how-to-save-a-text-file-in-external-storage-in-ios-using-flutter


### Android

```
/sdcard/Android/data/com.example.mirrortask/files/
```
### Building/releasing
Currently builds on flutter version 2.10.5 / Dart 2.16.2 / cocoapods 1.15.2

- New devices needs to be added to the apple developer portal
- Fastlane match needs to fetch the provisioning profile and update git repo and local keychain:  
```bundle exec fastlane match development```

- If certificate has expired, first run:  
`bundle exec fastlane match nuke development`

- Get firebase token from:  
`firebase login:ci`  
`export FIREBASE_TOKEN="tokenfromabove"`

- Update fastlane plugins  
`fastlane update_plugins`

- Build and deploy:  
From the ios folder:  
`bundle exec fastlane firebase_ios`


### Build errors
#### IPHONEOS_DEPLOYMENT_TARGET
After `flutter run`:
1. Uncomment ios target in top of Podfile
2. Change end of Podfile to:
```
post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
  end
 end
end
```
