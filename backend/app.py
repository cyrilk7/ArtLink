from flask import Flask, request, jsonify
from firebase_admin import credentials, firestore, initialize_app
from werkzeug.security import generate_password_hash, check_password_hash
import datetime
from flask_jwt_extended import create_access_token, JWTManager, get_jwt_identity, jwt_required
import secrets
from datetime import timedelta, datetime
from dotenv import load_dotenv
import os


load_dotenv()

# Initialize Flask App
app = Flask(__name__)
# Generate a secure random key
app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY")

# Initialize Firestore DB
cred = credentials.Certificate('artlink-56f38-firebase-adminsdk-2th85-a12925cada.json')
default_app = initialize_app(cred)
db = firestore.client()
users_ref = db.collection('users')
# Initialize JWT manager
jwt = JWTManager(app)

# In-memory blacklist for revoked tokens 
blacklist = set()

# Custom JWT loaders to handle token expiration
# @jwt.token_in_blacklist_loader
# def check_if_token_in_blacklist(decrypted_token):
#     jti = decrypted_token['jti']
#     return jti in blacklist


def format_timestamp(timestamp):
    if timestamp:
        return datetime.fromtimestamp(timestamp.timestamp()).date().isoformat()
    else:
        return None


@app.route('/users', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        
        # Extracting data from the request
        username = data.get('username')
        first_name = data.get('first_name')
        last_name = data.get('last_name')
        phone_number = data.get('phone_number')
        dob = data.get('dob')
        email = data.get('email')
        gender = data.get('gender')
        password = data.get('password')

        # Validate required fields
        if not all([username, first_name, last_name, phone_number, dob, email, gender, password]):
            return jsonify({'success': False, 'message': 'All fields are required'}), 400

        # Check if username already exists
        username_check = db.collection('users').where('username', '==', username).limit(1).get()
        if username_check:
            return jsonify({'success': False, 'message': 'Username already exists'}), 400

        # Check if email already exists
        email_check = db.collection('users').where('email', '==', email).limit(1).get()
        if email_check:
            return jsonify({'success': False, 'message': 'Email already exists'}), 400

        # Hash the password
        hashed_password = generate_password_hash(password, method='pbkdf2:sha256')

        # Convert dob to a datetime object
        dob_date = datetime.datetime.strptime(dob, '%Y-%m-%d')

        # Create user data dictionary
        user_data = {
            'username': username,
            'first_name': first_name,
            'last_name': last_name,
            'phone_number': phone_number,
            'dob': dob_date,
            'email': email,
            'gender': gender,
            'password': hashed_password,
            'posts': [],
            'followers': [],
            'following': [],
            'created_at': firestore.SERVER_TIMESTAMP
        }

        # Add user data to Firestore with username as user_id
        users_ref.document(username).set(user_data)
        

        return jsonify({'success': True, 'user_id': username, 'message': 'User created successfully'}), 201

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


# Login route that returns a non-expiring token
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()

    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'message': 'Username and password are required'}), 400

    username = data.get('username')
    password = data.get('password')

    # Fetch user from Firestore
    try:
        user_ref = users_ref.document(username)
        user_doc = user_ref.get()
        if not user_doc.exists:
            return jsonify({"message": "User not found", "success": False}), 404

        user_data = user_doc.to_dict()
        stored_password_hash = user_data.get('password', None)
        if not stored_password_hash:
            return jsonify({"message": "Invalid user data", "success": False}), 500

        # Verify hashed password
        if not check_password_hash(stored_password_hash, password):
            return jsonify({"message": "Incorrect password", "success": False}), 401

        # Generate JWT token
        expires = timedelta(days=30)
        access_token = create_access_token(username, expires_delta=expires)
        return jsonify({"access_token": access_token, "success": True}), 200

    except Exception as e:
        return jsonify({"message": f"Error fetching user: {str(e)}"}), 500

@app.route('/view_profile', methods=['GET'])
@jwt_required()
def view_profile():
    current_user = get_jwt_identity()

    # Get user document
    user_ref = users_ref.document(current_user)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        dob_timestamp = user_data.get('dob')
        if dob_timestamp:
            # Convert Firestore timestamp to a readable date format
            dob = format_timestamp(dob_timestamp)
        response = {
            "username": current_user,
            "email": user_data.get("email", ""),
            "first_name": user_data.get("first_name", ""),
            "last_name": user_data.get("last_name", ""),
            "gender": user_data.get("gender", ""),
            "phone_number": user_data.get("phone_number", ""),
            "posts":  user_data.get("posts", ""),
            "followers":  user_data.get("followers", ""),
            "following":  user_data.get("following", ""),
            "dob": dob,
        }
        return jsonify(response), 200

    else:
        return jsonify({"error": "User not found"}), 404
@app.route('/edit_profile', methods=['PUT'])
@jwt_required()
def edit_profile():
    try:
        # Get the current user's identity
        current_user = get_jwt_identity()

        # Get the request data
        data = request.get_json()

        # Define allowed fields for updating
        allowed_fields = ['first_name', 'last_name', 'phone_number', 'email']

        # Prepare the update data
        update_data = {}
        for field in allowed_fields:
            if field in data:
                update_data[field] = data[field]

        # Validate that there's at least one field to update
        if not update_data:
            return jsonify({'success': False, 'message': 'No valid fields provided for update'}), 400

        # Update the Firestore document
        user_ref = users_ref.document(current_user)
        user_ref.update(update_data)

        return jsonify({'success': True, 'message': 'Profile updated successfully'}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500




if __name__ == '__main__':
    app.run(debug=True)