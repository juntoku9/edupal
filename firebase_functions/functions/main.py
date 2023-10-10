# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn, options
from firebase_admin import initialize_app, firestore, auth
from speech_utils import get_transcript, generate_bot_response, pcm16_to_wav, generate_speech, aac_to_wav_in_memory
import requests
import json 
import io
from google.cloud.firestore_v1.base_query import FieldFilter
from datetime import datetime, timezone, timedelta

initialize_app()

def fetch_messages(session_id, character):
    firestore_client = firestore.Client()
    
    # Filter by session_id and character, then order by timestamp
    query = (firestore_client.collection("messages")
             .where("session_id", "==", session_id)
             .where("character", "==", character)
             .order_by("timestamp"))
    
    messages = [doc.to_dict() for doc in query.stream()]
    return messages

def save_message_to_firestore(message_data):
    # Initialize Firestore client if not done
    db = firestore.client()

    # Create the new message document  
    message_data['timestamp'] = firestore.SERVER_TIMESTAMP
    message_ref = db.collection('messages').add(message_data)

    ### after saving return the message 
    message_data['timestamp'] = datetime.utcnow().isoformat() + "Z"


@https_fn.on_request(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["post"])
)
def process_speech_input(req: https_fn.Request) -> https_fn.Response:
    if not req.form.to_dict():
        # this might be preflight 
        return https_fn.Response("ok")
    data = req.form.to_dict()['json_data']
    data = json.loads(data)
    print(data)
    session_id = data['session_id']
    language = data['language']
    character = data['character']

    audio_file = req.files.get('audio.m4a')
    print("getting wav data")
    # audio_file.save("temp_file.m4a")
    # now convert the audio file to wav format
    # Read the bytes from the FileStorage object
    audio_data = audio_file.read()
    
    # Convert the PCM16 audio to WAV
    wav_data = pcm16_to_wav(audio_data)
    # audio_content = audi_file.read()
    # with open("temp.wav", "wb") as f:
    #     f.write(audio_content)
    # now process the audio file to get the transcript 
    transcript = get_transcript(wav_data)
    transcript_text = transcript['text']
    print(transcript_text)

    save_message_to_firestore({"message": transcript_text, "side": "user", "session_id": session_id, "character": character})
    ### now simply generate a response for the dog 
    past_msgs = fetch_messages(session_id, character)
    response = generate_bot_response(transcript_text, past_msgs, language)
    save_message_to_firestore({"message": response, "side": "bot", "session_id": session_id, "character": character})
    ### it will generate a sentence 
    ## generate the response 
    ### genrate the audio file 
    audio_data = generate_speech(response)
    

    response_data = {
        "status": "success",
        "message": "response",
        "audio_data": audio_data
    }

    return https_fn.Response(json.dumps(response_data))

