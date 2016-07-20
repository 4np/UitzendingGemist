# NPOKit

```NPOKit``` is a native iOS library developed in [Swift](https://developer.apple.com/swift/) for interfacing with the Nederlandse Publieke Omroep's (e.g. NPO, the Dutch public broadcaster) [Uitzending Gemist API](http://www.npo.nl/uitzending-gemist). The library is specifically developed for the *unofficial* open source [Uitzending Gemist](https://github.com/4np/UitzendingGemist) application for Apple TV 4.

Currently the library only supports ```tvOS```, but support might become wider in the future.

## Installation

### Cocoapods

Add the following lines to your ```Podfile```:

```
use_frameworks!

pod 'NPOKit', :git => 'https://github.com/4np/NPOKit.git'
```

Then import it where you use it:

```
import NPOKit
```

### Carthage

_Todo_

### Swift Package Manager

_Todo_

## APIManager

The ```APIManager``` is the main manager to interact with and allows you to fetch programs, episodes and images, (un)favoriting programs, keep track of (partially) played episodes and fetch video stream URLs.

### Fetch tips

The complettion closure returns an optional array of tips (e.g. ```[NPOTip]?```):

```
NPOManager.sharedInstance.getTips() { [weak self] tips, error in
	guard let tips = tips else {
		DDLogError("Could not fetch tips (\(error))")
		return
	}
	
	// assign tips
	self?.tips = tips
}

### Fetch programs

The completion closure returns an optional array of programs (e.g. ```[NPOProgram]?```):

```
NPOManager.sharedInstance.getPrograms() { programs, error in ... }
```

### Fetch (details of) a single program

The completion closure returns an optional program (e.g. ```NPOProgram?```):

```
NPOManager.sharedInstance.getDetails(forProgram: NPOProgram) { program, error in ... }
```

### Fetch popular episodes

The completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```):

```
NPOManager.sharedInstance.getPopularEpisodes() { episodes, error in ... }
```

### Fetch recent episodes

The completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```):

```
NPOManager.sharedInstance.getRecentEpisodes() { episodes, error in ... }
```

### Fetch (details of) a single episode

The completion closure returns an optional program (e.g. ```NPOEpisode?```):

```
NPOManager.sharedInstance.getDetails(forEpisode: NPOEpisode) { episode, error in ... }
```

### Fetch episodes by genre

The function takes an argument of _enum_ type ```NPOGenre``` and the completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```):

```
NPOManager.sharedInstance.getEpisodes(byGenre: NPOGenre) { episodes, error in ... }
```

### Fetch episodes by broadcaster

The function takes an argument of _enum_ type ```NPOBroadcaster``` and the completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```):

```
NPOManager.sharedInstance.getEpisodes(byBroadcaster: NPOBroadcaster) { episodes, error in ... }
```

### Fetch episodes by date

The function takes an argument of type ```NSDate``` and the completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```) for the whole day that date falls in:

```
NPOManager.sharedInstance.getEpisodes(forDate: NSDate) { episodes, error in ... }
```

### Fetch episodes by program

The function takes an argument of type ```NSProgram``` and the completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```):

```
NPOManager.sharedInstance.getEpisodes(forProgram: NSProgram) { episodes, error in ... }
```

### Fetch the latest episode for a program

The function takes an argument of type ```NSProgram``` and the completion closure returns an optional episode (e.g. ```NPOEpisode?```):

```
NPOManager.sharedInstance.getLatestEpisode(forProgram: NSProgram) { episode, error in ... }
```

### Fetch the next episode for a program

The function takes an argument of type ```NSProgram``` and the completion closure returns an optional episode (e.g. ```NPOEpisode?```):

```
NPOManager.sharedInstance.getNextEpisode(forProgram: NSProgram) { episode, error in ... }
```

_Note: as this is a *future* episode, there is no video stream available yet_

### Search episodes

The function takes an argument of type ```String``` and the completion closure returns an optional array of episodes (e.g. ```[NPOEpisode]?```):

```
NPOManager.sharedInstance.getEpisodes(bySearchTerm: String) { episodes, error in ... }
```

### Get the image for a program

The function takes an argument of type ```NPOProgram``` and the completion closure returns an optional image (e.g. ```UIImage?```):

```
func getImage() {
	let program: NPOProgram = ...
	let request = program.getImage() { [weak self] image, error, request in
		guard let myRequest = self?.request where request == myRequest else {
			// This is the result of another request, which might for example
			// happen in reusable cells in collection views. Ignore it...
			// We could also cancel it via request.cancel()
			return 
		}
	
		self?.doSomething(withImage: image)
	}
}
```

_Note: the request is cancellable via ```request.cancel()```_

### Get the properly sized image for a program

The function takes an argument of type ```NPOProgram``` and the completion closure returns an optional image (e.g. ```UIImage?```):

```
let myImageView: UIImageView = ...

func getImage() {
	let program: NPOProgram = ...
	let request = program.getImage(ofSize: self.myImageView.frame.size) { [weak self] image, error, request in
		guard let myRequest = self?.request where request == myRequest else {
			// This is the result of another request, which might for example
			// happen in reusable cells in collection views. Ignore it...
			// We could also cancel it via request.cancel()
			return 
		}
	
		self?.myImageView.image = image
	}
}
```

_Note: the request is cancellable via ```request.cancel()```_

### Get the image for an episode

The function takes an argument of type ```NPOEpisode``` and the completion closure returns an optional image (e.g. ```UIImage?```):

```
let episode: NPOEpisode = ...
let request = episode.getImage() { [weak self] image, error, request in ... }
```

### Get the properly sized image for an episode

The function takes an argument of type ```NPOEpisode``` and the completion closure returns an optional image (e.g. ```UIImage?```):

```
let episode: NPOEpisode = ...
let request = episode.getImage(ofSize: CGSize) { [weak self] image, error, request in ... }
```

### Get the video stream URL of an episode

The completion closure returns an optional url (e.g. ```NSURL?```) which can be used to feed into a video player (for example into ```AVPlayer```):

```
let episode: NPOEpisode = ...
episode.getVideoStream() { url, error in ... }
```

## Special API

hile the other API methods are all about interfacing with the NPO, NPOKit also includes convencience methods for simplifying some other tasks.

### GitHub Latest Releases API

The [Uitzending Gemist App](https://github.com/4np/UitzendingGemist) uses this API method to provide version update notifications to the end user. As the app is distributed by source on Github it does not tap into the native AppStore to push version updates. To make sure users are aware of version updates this API is used to determine whether or not updates are available.

```
let githubUsername = "4np"
let githubRepository = "UitzendingGemist"
NPOManager.sharedInstance.getGitHubReleases(forUsername: githubUsername, andRepositoryName: githubRepository) { releases, currentVersion in
	...
}
```

### Get the latest GitHub releases

# License

See the accompanying [LICENSE](LICENSE) and [NOTICE](NOTICE) files for more information.

```
Copyright 2016 Jeroen Wesbeek

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```