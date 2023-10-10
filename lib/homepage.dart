import 'dart:io';
import 'dart:async';

import 'package:coda_ai/profile_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'functions/message_utils.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:record/record.dart';
import 'package:google_speech/google_speech.dart';
import 'package:just_audio/just_audio.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {  
  // FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  // late final RecorderController recorderController;
  TextEditingController textController = TextEditingController();
  String languageDropDownValue = 'English';
  String speechFinalized = "";
  String speechInterimBuffer = "";
  String _sessionId = Uuid().v4();

  final _player = AudioPlayer();                   // Create a player
  // try the stream 
  final record = Record();
  bool _isRecording = false;
  String _talkingState = "idle";
  String  _curFilePath = "";
  late SpeechToText speechToText; 
  late StreamingRecognitionConfig streamingConfig;

  @override
  void initState() {
    super.initState();
    _getMicrophonePermission();
    // _initialiseController();
    // initialize google speech 
    // final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
  }

  late StreamController<List<int>> _audioController;
  
  void addAudio(List<int> audioData) {
    _audioController.add(audioData);
  }

  void _stopAudioController() {
    _audioController.close();
  }

  // Separate async function to load your data
  Future<void> _initializeGoogleSpeech() async {
    // Perform your async operations here
    // For instance: final speechToText = await SpeechToText.viaServiceAccount(serviceAccount);
      String cred =  await rootBundle.loadString('your google speech key');
      final serviceAccount = ServiceAccount.fromString(cred);
      speechToText = SpeechToText.viaServiceAccount(serviceAccount);
      print("initialization complete");
  }
    
  @override
  void dispose() {
    // _recorder.closeRecorder();
    super.dispose();
  }

// Callback function if device capture new audio stream.
// argument is audio stream buffer captured through mictophone.
// Currentry, you can only get is as Float64List.
void listener(dynamic obj) {
  if(obj is List<dynamic>) {
    List<double> floatSamples = List<double>.from(obj);
    List<int> intSamples = floatSamples.map((double value) => (value * 32767).round()).toList();
    // print(intSamples);
    // responseStream.listen((data) {
    //     print("got audio stream");
    //     // listen for response 
    //     print(data);
    // });
    addAudio(intSamples);
  } else {
    print("Unexpected data received in listener");
  }
}

// Callback function if flutter_audio_capture failure to register
// audio capture stream subscription.
void onError(Object e) {
  print("there is an error");
  print(e);
}


// This method prepares the save path for the recording
// You may modify this as needed
Future<String> _prepareSavePath() async {
  final Directory tempDir = await getTemporaryDirectory();
  // Specify the file name, you may want to include timestamp or other identifiers in the file name
  final String filePath = '${tempDir.path}/flutter_sound_${DateTime.now().millisecondsSinceEpoch}.m4a';
  return filePath;
}
  void _startStopRecording(String character) async {
    // print(_recorder.recorderState);
    bool isRecording = await record.isRecording();
    print(isRecording);

    if (isRecording) {
      await record.stop();
      _postSoundRecording(_curFilePath, character);
      setState(() {
        _isRecording = false;
      });
    } else {
      // print("going to start recording");
      _curFilePath = await _prepareSavePath();
      // Create file
      setState(() {
        _isRecording = true;
      });
      if (await record.hasPermission()) {
        // Start recording
        print("goinhg to start recording...");
        await record.start(
          path: _curFilePath,
          encoder: AudioEncoder.pcm16bit, // by default
          numChannels: 1,
          samplingRate: 44100, // by default
        );
      }
    }
  }

  void _getMicrophonePermission() async {
    if (await Permission.microphone.isDenied) {
      Permission.microphone.request();
    }
  }

Future<void> _playAudio(Uint8List audioData) async {
    print("going to play audio");
    String tempPath = (await getTemporaryDirectory()).path;
    String filePath = '$tempPath/tempAudio.mp3';
    File tempAudioFile = File(filePath);
    await tempAudioFile.writeAsBytes(audioData);
    var fileExists = await File(filePath).exists();
    if (fileExists) {
      // Attempt to read the file and print its length (bytes)
      Uint8List fileContents = await tempAudioFile.readAsBytes();
      print('File byte length: ${fileContents.length}');
    } else {
      print("Error: File doesn't exist!");
      return;
    }

    final duration = await _player.setFilePath(filePath);
    await _player.play();                            // Play while waiting for completion
    await _player.stop();

}


Future<void> _postSoundRecording(String filePath, String character) async {
  String? accessToken = await getCurrentUserAccessToken();
  if (accessToken == null) {
    showErrorDialog(context, "Encountered Error", "Please login to use this feature");
    return;
  }
  // Load the sound file from filePath
  final bytes = await File(filePath).readAsBytes();
  print('${dotenv.env['VOICE_INPUT_ENDPOINT_URL']}');
  var url = Uri.parse('${dotenv.env['VOICE_INPUT_ENDPOINT_URL']}');
  var body = jsonEncode({"session_id": _sessionId, "language": languageDropDownValue, "character": character});

  // Create a multipart request
  var request = http.MultipartRequest('POST', url);
  // Add the json body to the request
  request.fields['json_data'] = body;
  // Add the file to the multipart request
  request.files.add(http.MultipartFile.fromBytes(
    'audio.m4a',
    bytes,
    filename: 'audio.m4a',
    contentType: MediaType('audio', 'm4a'),
  ));

    // Send the request and get a regular response
    setState(() {
      _talkingState = "loading";
    });
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Decode the response body
        var responseBodyJson = jsonDecode(response.body);
        // Decode the base64 encoded audio data
        var audioData = base64Decode(responseBodyJson['audio_data']);
        // Play the audio
        setState(() {
          _talkingState = "talking";
        });

        await _playAudio(audioData);
        setState(() {
          _talkingState = "idle";
        });
    } else {
        setState(() {
          _talkingState = "error";
        });
        print(response.body);
        print(response.statusCode);
        showErrorMessage(context, "error");
        return;
    }
}


  @override
  Widget build(BuildContext context) {
    final characterProvider = context.watch<CharacterProvider>();

    return GestureDetector(
        onTap: () {
          // Unfocus the TextField when the user taps outside of it
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child:Scaffold(
          appBar: AppBar(
          backgroundColor: Colors.transparent, // Making the AppBar background transparent
          elevation: 0, // Removing the shadow
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings, color: Colors.grey), // Use settings icon
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));  // Assuming you have a SettingsPage() widget
              },
            )
          ],
        ),

              resizeToAvoidBottomInset: true,
              body: Stack(
                children: [
                  Center( // Wraps the Column with a Center widget to center the items
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Container(
                            child: Center(
                              child: Image.asset(characterProvider.currentCharacter!['image']), // Replace 'assets/your_image.png' with the path to your image asset
                            ),
                          ),
                        // now build a select button 
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Current State Tag
                              Chip(
                                label: Text(
                                  'Current State: ${_talkingState}',  // Assuming currentState is your enum
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.deepPurple, // Use a color complementary to your theme
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                              ),

                              SizedBox(width: 20),  // For spacing

                              // DropdownButton
                              Expanded(
                                child: DropdownButton<String>(
                                  value: languageDropDownValue,
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      languageDropDownValue = newValue!;
                                    });
                                  },
                                  items: <String>['English', '中文', '日本語', 'French']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10), // Space between buttons
                        ElevatedButton(
                          onPressed: () {_startStopRecording(characterProvider.currentCharacter!['name']);},
                          style: ElevatedButton.styleFrom(
                            primary: _isRecording ? Colors.red : Colors.grey, // Change color based on recording state
                            onPrimary: Colors.white,
                            shape: CircleBorder(),  // Make it round
                            padding: EdgeInsets.all(35),  // Adjust this value for desired size
                            shadowColor: _isRecording ? Colors.red[700] : Colors.grey[700],
                            elevation: 5.0, // Add some shadow for depth
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, size: 25.0),  // Reduced size of the Microphone icon
                              SizedBox(height: 4.0),  // Reduced spacing between icon and text
                              Text(
                                _isRecording ? 'Stop' : 'Talk',
                                style: TextStyle(
                                  fontFamily: 'CuteFont',
                                  fontSize: 18,  // Reduced font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        ]
                      )
                    )
                  ],
                  ),
                )
            );
        }
  }
