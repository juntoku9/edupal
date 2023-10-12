# Edupal: AI companion for children
An open-source flutter AI pet companion for happy children

<p float="left">
  <img src="https://github.com/juntoku9/edupal/assets/92097440/31f5d936-0e4d-44f6-95bc-74bf0be18dd2" width="200" />
  <img src="https://github.com/juntoku9/edupal/assets/92097440/38c5b910-fdac-4f44-8d55-3254fcc64c2b" width="200" /> 
  <img src="https://github.com/juntoku9/edupal/assets/92097440/614148b1-e019-4319-a0aa-c7cf01984328" width="200" />
</p>

## 🐱 Demo

## 🔥 Key Features
- **Multilingal**: Currently our AI App can support 4 languages including English, Chinese, Japanese and French
- **Customizable**: You can select character to talk to.
- **Most up-to-date AI**: We use the most up-to-date AI technology to power your AI character, including OpenAI, Whisper, ElevenLabs, etc.

## 🪩 Website
Try our site at [edupal.io](https://edupal.webflow.io/)

## 🤓 Prerequisites
Here we will provide you a thorough end to end steps to help you run this project.

To develop Flutter apps for iOS, you need a **Mac** with **Xcode** installed.

*we are currently only support iOS app development. But Android app is under beta testing.*

### Getting API Keys

#### LLM -  OpenAI API Token
<details><summary>👇click me</summary>
This application utilizes the OpenAI API to access its powerful language model capabilities. In order to use the OpenAI API, you will need to obtain an API token.

To get your OpenAI API token, follow these steps:

1. Go to the [OpenAI website](https://beta.openai.com/signup/) and sign up for an account if you haven't already.
2. Once you're logged in, navigate to the [API keys page](https://beta.openai.com/account/api-keys).
3. Generate a new API key by clicking on the "Create API Key" button.
4. Copy the API key and store it safely.
</details>

#### Prepare Text to Speech - ElevenLabs API Key
<details><summary>👇click me</summary>

1. Creating an ElevenLabs Account

Visit [ElevenLabs](https://beta.elevenlabs.io/) to create an account. You'll need this to access the text to speech and voice cloning features.

2. In your Profile Setting, you can get an API Key. Save it in a safe place.

</details>

### Download Flutter
We are using **Flutter 3.7.11**. Make sure that you downloaded this version. Follow the [Instruction Guide](https://docs.flutter.dev/get-started/install/macos#get-sdk).

### Set Up iOS Development
Follow the iOS Set Up Guide [Here](https://docs.flutter.dev/get-started/install/macos#ios-setup)

### Download Firebase CLI
Follow the download instruction [Here](https://firebase.google.com/docs/cli#setup_update_cli)

## 😈 Getting Started

### Initialize Firebase

#### Create Firebase Project
- Log in to your firebase using
```bash
$ firebase login
```
- **Step 1**: Go to [Firebase](https://firebase.google.com/), get started and create a project. Name your project name of your choice, for example, we used edupal

- **Step 2**: In your clone repository, navigate the terminal  to the project repo, run
```bash
$ firebase init
```
- **Step 3**: Choose the "Functions" feature
- **Step 4**: Choose Use an existing project
- **Step 5**: Select the project you created in Step 1, and choose python to be your language
---
If you want to reuse the existing firebase functions you should follow the steps below
- **Step 6**: Copy all the files in firebase_functions/functions to functions/ and then install dependencies
- **Step 7**: Uncomment lines that you need in main.py and speech_utils.py

#### Add Firebase to your Flutter app
In your project repo, run
```bash
$ dart pub global activate flutterfire_cli
# and
$ flutterfire configure --project=<YOUR_PROJECT_ID> # Can be found in .firebaserc in your local repo
```

In the config.json file, change the API Key to what you get in previous Getting API Keys steps

#### Set up Firebase Auth

- Go to your newly created firebase project in the [Console](https://console.firebase.google.com/)
- On the leftside, under Build Selection, select Authentication
- Click Get Start, Enable: Email/Password, Google, Apple

#### Change to your own config
Search in your codebase with "INPUT_YOUR_OWN", and change the ids and keys accordingly

#### Deploy Firebase Project

Run
```bash
$ firebase deploy
```

#### Run your app locally
```bash
$ flutter run
```


