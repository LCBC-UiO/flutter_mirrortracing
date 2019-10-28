# mirrortask

## object image


* blue channel: boundaries
* green channel: inside object
* alpha channel: blue|green
* height=width
* high resolution (will be downscaled within the app)


## TODO

- submit "app id" to nettskjema

- test max upload size / big trajectories
- recalc line from trajectory
- local JSON + image - not accessible on ios`
- also save to local DB?
- save autocomplete info in results?


## locally saved files (iOS)
"To make the directory available to the user you need to open the Xcode project under 'your_app/ios/Runner.xcworkspace'. Then open the Info.plist file in the Runner directory and add two rows with the key UIFileSharingEnabled and LSSupportsOpeningDocumentsInPlace. Set the value of both keys to YES.
If you now open the Files app and click on 'On My iPhone' you should see a folder with the name of your application."

https://stackoverflow.com/questions/55220612/how-to-save-a-text-file-in-external-storage-in-ios-using-flutter
