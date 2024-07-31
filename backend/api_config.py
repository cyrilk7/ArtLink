from flask import Flask
from firebase_admin import credentials, firestore, initialize_app, storage
from flask_jwt_extended import JWTManager
from dotenv import load_dotenv
import os

load_dotenv()

# Initialize Flask App
app = Flask(__name__)

# Generate a secure random key
app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY")

# Initialize Firestore DB
cred = credentials.Certificate('artlink-56f38-firebase-adminsdk-2th85-a12925cada.json')
default_app = initialize_app(cred, {
        'storageBucket': 'artlink-56f38.appspot.com'
        })
db = firestore.client()
bucket = storage.bucket()
users_ref = db.collection('users')
blacklist_ref = db.collection('blacklisted_tokens')
# Initialize JWT manager
jwt = JWTManager(app)