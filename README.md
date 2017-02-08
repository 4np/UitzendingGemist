# ![Apple TV](https://cloud.githubusercontent.com/assets/1049693/11407062/c1891a92-93b0-11e5-9270-745cf4fa4152.png) Uitzending Gemist 

[![Build Status](https://travis-ci.org/4np/UitzendingGemist.svg?branch=master)](https://travis-ci.org/4np/UitzendingGemist)
[![Release](https://img.shields.io/github/release/4np/UitzendingGemist.svg)](https://github.com/4np/UitzendingGemist/releases/latest)
[![Commits Since](https://img.shields.io/github/commits-since/4np/UitzendingGemist/1.2.0.svg?maxAge=3600)](https://github.com/4np/UitzendingGemist/commits/master)
[![Platform](https://img.shields.io/badge/platform-tvOS%2010-green.svg?maxAge=3600)](https://developer.apple.com/tvos/)
[![Swift](https://img.shields.io/badge/language-Swift-ed523f.svg?maxAge=3600)](https://swift.org)
[![codebeat badge](https://codebeat.co/badges/a5990b60-12ce-4f22-a875-31b2ccaecfcd)](https://codebeat.co/projects/github-com-4np-uitzendinggemist)
[![Open Issues](https://img.shields.io/github/issues/4np/UitzendingGemist.svg?maxAge=3600)](https://github.com/4np/UitzendingGemist/issues)
[![Closed Issues](https://img.shields.io/github/issues-closed/4np/UitzendingGemist.svg?maxAge=3600)](https://github.com/4np/UitzendingGemist/issues?q=is%3Aissue+is%3Aclosed)

```UitzendingGemist``` is an unofficial native ```Uitzending Gemist``` and ```NPO Live``` application for the Apple TV 4 developed in [Swift](https://developer.apple.com/swift/). It will allow you to browse and watch all video streams of the Nederlandse Publieke Omroep's (e.g. NPO, the Dutch public broadcaster) [Uitzending Gemist](http://www.npo.nl/uitzending-gemist) website on your Apple TV.

![TopShelf](https://github.com/4np/UitzendingGemist/blob/master/UitzendingGemist/Assets.xcassets/App%20Icon%20&%20Top%20Shelf%20Image.brandassets/Top%20Shelf%20Image.imageset/TopShelf.png?raw=true)

Watching videos is very snappy and almost instantaneous, contrary to streaming from your iDevice to Apple TV over Airplay or using the built-in player in your smart tv. This is a _truly_ native app contrary to some of the other apps that I have seen which are basically webcontainers
using a web app hosted on a remote server.

# Features

- Fast *_native_* app for Apple TV
- Easy to use interface for browsing Programs and Episodes
- The possibility to (un)favorite programs
- Remembers watched episodes and will allow you to resume watching
- Will show you new unwatched episodes of favorite programs
- Live TV (and NPO1, NPO2 and NPO3 in high quality) and themed channels
- The ability to watch YouTube videos for Programs that have [YouTube Resources](https://github.com/4np/NPOKitResources)

# Okay, that's all great! But how do I get this on my ![Apple TV](https://cloud.githubusercontent.com/assets/1049693/11407062/c1891a92-93b0-11e5-9270-745cf4fa4152.png)?

Unfortunately the app cannot be distributed in the Appstore as the NPO does not allow third parties in doing so. However, using a _free_ Apple Developer account you *can* compile it yourself and install it in your own Apple TV 4 (_but also read the note below_). 

**Prerequisites:**

- an [Apple TV](http://www.apple.com/tv/) 4th generation (the one that has an AppStore)
- a recent Apple Computer running ```macOS 10.11.x El Capitan or higher```
- a (free) Apple Developer account (signup [here](http://developer.apple.com))
- a [USB-C cable](http://www.apple.com/nl/shop/product/HHSP2ZM/B/belkin-usb-c-naar-usb-a-oplaadkabel?fnode=85) to connect your Apple TV to your Apple Computer

_Note: as of summer 2016 Apple has reduced the free Developer account provisioning from 90 days to a mere 7 days, which means when you are using a free Apple Developer Account the application [will expire every 7 days](http://mybyways.com/blog/new-limitations-imposed-on-free-apple-developer-account) after which you need to re-deploy the app (make sure to keep your bundle identifier the same for your favorites to stick). The paid Apple Developer Accounts do not have a time based limitation and deployed apps will continue to work during the lifetime of your subscription._

## 1. Xcode

The code was developed in [Xcode 8.2.1](https://itunes.apple.com/nl/app/xcode/id497799835?mt=12) ([alternative link](https://developer.apple.com/xcode/download/)) so you need at least to have that version installed. Continue with the following steps when you have finished installing ```Xcode``` as the next steps require a finished installation.

## 2. Clone the project

It is advisable to have a ```Developer``` folder on your machine. Execute the following code in ```Terminal``` to create those folders and clone this project:

```
mkdir -p ~/Developer/tvOS
cd ~/Developer/tvOS
git clone https://github.com/4np/UitzendingGemist.git
cd UitzendingGemist
```

## 3. Open the project

Now that everything is in place, you can open the project file ```UitzendingGemist.xcworkspace``` (and _not_ the ```xcodeproj``` file)in ```Finder```. Alternatively, when you still have ```Terminal``` open you can also execute the following command:

```
open UitzendingGemist.xcworkspace
```

## 4. Connect the Apple TV 4 to your computer

Connect the ```Apple TV 4``` using the USB-C cable to your Mac and perform / click through the following steps in Xcode:

![Steps to perform](https://cloud.githubusercontent.com/assets/1049693/20404995/8b810916-ad07-11e6-8715-87b3732ecf3a.png)

## 5. Change the Bundle Identifier

The bundle identifier (see **4** in the screenshot above) uniquely identifies your app. As you cannot reuse mine, you need to set your own bundle identifier in reverse domain format (for example: com.yourname.UitzendingGemist). Make sure you remember the name as you will need to enter the same bundle identifier when you want to update or re-deploy the app to your AppleTV.

_Note: using a different identifier will make the app deploy next to a previous installation and separate favorites. Keeping the identifier the same will make the favorites continue to work after updates. Also *free* Apple Developer Accounts have a limit on the number of different identifiers you can create on a weekly basis (10)._

## 6. Select the team

In order to deploy the application to the Apple TV it needs to be signed with your team (see **5** in the screenshot above). If you do not have a team (e.g. ```None```), or you see the message ```No Matching provisioning profiles found``` click the ```Fix Issue``` and login with your Apple ID / Apple Developer Account credentials.

## 7. Select the Build Device

On the top left in Xcode click on the device the compiled program will be deployed to (see **6** in the screenshot above). If your Apple TV 4 is properly connected you will be able to pick you Apple TV device (otherwise it will run in the Simulator).

## 8. Run the application

Finally you are able to compile the program and deploy it onto your Apple TV! Click the play icon (see **7** in the screenshot above). The application will be compiled and deployed on your Apple TV 4. After this the application will remain on the Apple TV. 

## 9. Sit back and enjoy :)

You're done! You can disconnect your Apple TV and start watching! :)

# Firewalls

If you have set up a firewall to filter outbound network requests, make sure to configure it to allow the following URL patterns you can expect the app to call (also see #18):

- apps-api.uitzendinggemist.nl (the API)
- api.github.com (check for new releases)
- *.omroep.nl (images, videos and live streams)
- googleapis.com (youtube API)
- youtube.com (youtube videos)

_Note: as the video and image content URLs come from the APIs, although unlikely, these URLs *might* change_

# Screenshots

## Application Icon

![App Icon](https://cloud.githubusercontent.com/assets/1049693/17006428/12c66edc-4ee1-11e6-9e4a-0f057bcad5bf.gif)

## Application screen with Application Icon and Top Shelf image

![Main Screen](https://cloud.githubusercontent.com/assets/1049693/11430705/e585f7aa-948a-11e5-8b4d-a35dc1ab617a.png)

## Tip Screen

![Tip Screen](https://cloud.githubusercontent.com/assets/1049693/18724167/ba26d9ba-803b-11e6-9c76-2f44c47d2dee.png)

## Episode Screen

![Episode Screen](https://cloud.githubusercontent.com/assets/1049693/17333941/b3440e30-58d4-11e6-8338-1e450b8b29db.png)

## Continue Watching

![Continue Watching](https://cloud.githubusercontent.com/assets/1049693/17069835/116a35fe-5059-11e6-8e21-bf75d2209732.png)

## Program Screen

![Program Screen](https://cloud.githubusercontent.com/assets/1049693/17334014/f9e93978-58d4-11e6-8a81-aed35d100ff5.png)

## By Day Screen

![By Day](https://cloud.githubusercontent.com/assets/1049693/17333843/448ba638-58d4-11e6-9934-6c2faa973cbb.png)

## By Program Screen

![By Program](https://cloud.githubusercontent.com/assets/1049693/17334126/57f71c38-58d5-11e6-9dfe-d4f1a4ddbb45.png)

## Live TV Screen

![Live TV](https://cloud.githubusercontent.com/assets/1049693/18724305/479ddd3e-803c-11e6-912d-674eb207198a.png)

## Update Screen

![Update Screen](https://cloud.githubusercontent.com/assets/1049693/17013518/61df0220-4f1f-11e6-81eb-340f0fe0c452.png)

## Program with a YouTube channel

![YouTube Button](https://cloud.githubusercontent.com/assets/1049693/20447426/08b7e0da-addf-11e6-90a3-fc3a094a8d92.png)

![YouTube Channel](https://cloud.githubusercontent.com/assets/1049693/20447425/08aaed3a-addf-11e6-88f8-346ed87f6ca9.png)

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

