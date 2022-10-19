#  Vocabulometer-OSS

## Overview
This repository provides open source mobile app for vocabulary acquisition.
The app is based on a mobile app which is called "Mobile Vocabulometer".
"Mobile Vocabulometer" was introduced in UbiComp-ISWC '20. ([Mobile vocabulometer: a context-based learning mobile application to enhance English vocabulary acquisition](https://dl.acm.org/doi/10.1145/3410530.3414406))

## Set up
### CocoaPods (if necessary)
In this Xcode project, I'm using [CocoaPods](https://cocoapods.org/) to manage third party packages.
If you haven't installed Cocoapods to your Mac, please install.
```
sudo gem install cocoapods
```
If you have failed to install CocoaPods with the command above, please try this:
```
sudo gem install -n /usr/local/bin cocoapods
```

### Open workspace
Please open the Xcode workspace (`*.xcworkspace`) instead of the project file (`*.xcodeproj`) when building your project.

## Dependecies
### CocoaPods
If you need to add or remove packages, please open and edit `Podfile`.

## Datasets
### Newsela
In this repository, I will not share text data (JSON) for the article views due to its licence. To request the datasets, please first obtain access to [Newsela](https://newsela.com/data/), then contact me.

If possible, I will try to prepare sample data with no licence.

When you have obtained Newsela original datasets, you'll need modifications to the datasets. Here's a basic description and structure of the data that I modified for this project.

- Description: modified Newsela JSON data that includes grade level value, article categories, article titles, article texts.
- Dataset structure:
```
{
    "level": 2,
    "entertainment": [
        {
            "id": 1,
            "title": "Lorem Ipsum",
            "text": "## What is Lorem Ipsum?\n\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        },
        ...
    ],
    "economy": [
        ...
    ],
    ...
}
```

## Organization
- [Intelligient Media Processing Group, Osaka Metropolitan University](https://imlab.jp/index-e.html)

## Licence
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

under construction ...
