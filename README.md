# AudioPlayerTestApp
Test app for iOS developer position.

### Requirements
Create app which will load JSON data from specified API, display it and act as audio player. JSON data contains information about albums, artists and tracks. Player should play music which is stored locally.

### Realisation
There is no third-party frameworks in project, everythin written using standard Apple frameworks.
Integrated Core Data support for storing data between sessions.
SQLite db file stored in "Documents" app folder, all other downloadable content (images for albums, tracks and artists) stored in "Caches" directory.
Most UIKit components uses IB_DESIGNABLE feature and can be customized from Interface Builder directly.
At frist, albums and tracks looks similar and it made bad UX. To solve this problem I used "color code" to differentiate objects from each other. Albums has components in orange color and Tracks - in blue colors.

*To add support for playing audio when app is in background, you should add "audio" key to "UIBackgroundModes" in info.plist file.*

Player was realized with AVAudioPlayer. Also added support to control audio playback when app is in background with MPRemoteCommandCenter. 

### Improvements
Improve landscape support. UI components in landscape mode are too big.
Improve offline support and caching. When app starts it reload data completely, cleaning out all albums related data.
