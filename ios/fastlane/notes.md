1) install fastlane
2) bundle exec fastlane add_plugin firebase_app_distribution
3) check Gemfile plgin path: plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
4) check bundle exec fastlane update_plugins work
5) bundle update / bundle exec fastlane install_plugins
6) If podfile error message when building, delete podfile/podfile.lock
7) Remember "get started" on firebase.