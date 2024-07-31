from flask import request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
import datetime
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required
from datetime import timedelta, datetime, timezone
from dotenv import load_dotenv
import os
from api_config import app, db, bucket
from firebase_admin import messaging, firestore

users_ref = db.collection('users')
blacklist_ref = db.collection('blacklisted_tokens')
blacklist = set()


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
        dob_date = datetime.strptime(dob, '%Y-%m-%d')

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
            'profile_image': "",
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

        user_ref = users_ref.document(username)
        user_ref.update({'fcmtoken': data.get('fcmToken')})
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

        # Retrieve the list of post IDs
        post_ids = user_data.get("posts", [])
        
        # Fetch details of all posts
        posts = []
        for post_id in post_ids:
            post_ref = db.collection('posts').document(post_id)
            post_doc = post_ref.get()
            if post_doc.exists:
                post_data = post_doc.to_dict()
                timestamp_str = post_data.get('timestamp', None)
                post_timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
                time_ago_str = time_ago(post_timestamp)
                
                post_response = {
                    'post_id': post_id,
                    'likes': post_data.get('likes'),
                    'comments': post_data.get('comments'),
                    'username': post_data.get('username'),
                    'first_name': user_data.get('first_name', ''),
                    'last_name': user_data.get('last_name', ''),
                    'profile_image': user_data.get('profile_image', ''),
                    'content': post_data.get('content'),
                    'image_url': post_data.get('image_url', None),
                    'time_ago': time_ago_str,
                    'time_stamp': post_timestamp,
                    'isLiked': current_user in post_data.get('likes'),
                    'this_user': post_data.get('username') == current_user
                }
                posts.append(post_response)

        posts.sort(key=lambda x: x['time_stamp'], reverse=True)
        response = {
            "username": current_user,
            "profile_image" : user_data.get('profile_image', ''),
            "email": user_data.get("email", ""),
            "first_name": user_data.get("first_name", ""),
            "last_name": user_data.get("last_name", ""),
            "gender": user_data.get("gender", ""),
            "phone_number": user_data.get("phone_number", ""),
            "posts": posts,  # Include full post objects
            "followers": user_data.get("followers", ""),
            "following": user_data.get("following", ""),
            "dob": dob,
        }
        return jsonify(response), 200

    else:
        return jsonify({"error": "User not found"}), 404


@app.route('/view_profile/<username>', methods=['GET'])
@jwt_required()
def view_profile_by_id(username):
    current_user = get_jwt_identity()

    # Get user document
    user_ref = users_ref.document(username)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        dob_timestamp = user_data.get('dob')
        if dob_timestamp:
            # Convert Firestore timestamp to a readable date format
            dob = format_timestamp(dob_timestamp)

        # Retrieve the list of post IDs
        post_ids = user_data.get("posts", [])
        
        # Fetch details of all posts
        posts = []
        for post_id in post_ids:
            post_ref = db.collection('posts').document(post_id)
            post_doc = post_ref.get()
            if post_doc.exists:
                post_data = post_doc.to_dict()
                timestamp_str = post_data.get('timestamp', None)
                post_timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
                time_ago_str = time_ago(post_timestamp)
                
                
                post_response = {
                    'post_id': post_id,
                    'likes': post_data.get('likes'),
                    'comments': post_data.get('comments'),
                    'username': post_data.get('username'),
                    'first_name': user_data.get('first_name', ''),
                    'last_name': user_data.get('last_name', ''),
                    'profile_image': user_data.get('profile_image', ''),
                    'content': post_data.get('content'),
                    'image_url': post_data.get('image_url', None),
                    'time_ago': time_ago_str,
                    'time_stamp': post_timestamp,
                    'isLiked': current_user in post_data.get('likes'),
                    'this_user': post_data.get('username') == current_user
                }
                posts.append(post_response)

        posts.sort(key=lambda x: x['time_stamp'], reverse=True)
        response = {
            "username": username,
            "profile_image" : user_data.get('profile_image', ''),
            "email": user_data.get("email", ""),
            "first_name": user_data.get("first_name", ""),
            "last_name": user_data.get("last_name", ""),
            "gender": user_data.get("gender", ""),
            "phone_number": user_data.get("phone_number", ""),
            "posts": posts,  # Include full post objects
            "followers": user_data.get("followers", ""),
            "following": user_data.get("following", ""),
            "dob": dob,
            "isFollowing": current_user in user_data.get("followers")
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
        data = request.form


        # Define allowed fields for updating
        allowed_fields = ['first_name', 'last_name', 'phone_number', 'email']

        # Prepare the update data
        update_data = {}
        for field in allowed_fields:
            if field in data:
                update_data[field] = data[field]

        if 'file' in request.files:
            file = request.files['file']
            if file.filename == '':
                pass
            else:
                # Upload the image to Firebase Storage
                blob = bucket.blob(f'profile_images/{file.filename}')
                blob.upload_from_file(file)

                # Make the file publicly accessible
                blob.make_public()
                image_url = blob.public_url
                update_data["profile_image"] = image_url

        # Validate that there's at least one field to update
        if not update_data:
            return jsonify({'success': False, 'message': 'No valid fields provided for update'}), 400

        # Update the Firestore document
        user_ref = users_ref.document(current_user)
        user_ref.update(update_data)

        return jsonify({'success': True, 'message': 'Profile updated successfully'}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/create_post', methods=['POST'])
@jwt_required()
def create_post():
    try:
        # Parse the request data
        current_user = get_jwt_identity()
        post_content = request.form.get('content')
        likes = request.form.get('likes', []) # Default to empty list if not provided
        comments = request.form.get('comments', [])  # Default to empty list if not provided
        image_url = ""

        if not current_user or not post_content:
            return jsonify({'error': 'Missing required fields'}), 400
        
        if 'file' in request.files:
            file = request.files['file']
            if file.filename == '':
                pass
            else:
                # Upload the image to Firebase Storage
                blob = bucket.blob(f'post_images/{file.filename}')
                blob.upload_from_file(file)

                # Make the file publicly accessible
                blob.make_public()
                image_url = blob.public_url

        # Set the timestamp to the current time
        timestamp = datetime.utcnow().isoformat() + 'Z'

        # Prepare the post data
        post_data = {
            'username': current_user,
            'content': post_content,
            'timestamp': timestamp,
            'image_url': image_url,
            'likes': likes,
            'comments': comments
        }

        # Add the post to Firestore
        post_ref = db.collection('posts').document()
        post_ref.set(post_data)

        # Get the user document reference
        user_ref = db.collection('users').document(current_user)

        # Update the user's posts list with the new post ID
        user_doc = user_ref.get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            posts_list = user_data.get('posts', [])  # Get the existing posts list, default to empty list if not found
            posts_list.append(post_ref.id)  # Add the new post ID to the list
            user_ref.update({'posts': posts_list})


        return jsonify({'id': post_ref.id, 'status': 'Post created successfully'}), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500

def time_ago(post_timestamp):
    now = datetime.now(timezone.utc)  # Use timezone-aware current time
    elapsed_time = now - post_timestamp
    seconds = int(elapsed_time.total_seconds())
    
    if seconds < 60:
        return f"{seconds} secs"
    elif seconds < 3600:
        minutes = seconds // 60
        return f"{minutes} mins"
    elif seconds < 86400:
        hours = seconds // 3600
        return f"{hours} hrs"
    else:
        days = seconds // 86400
        return f"{days} days"


@app.route('/posts', methods=['GET'])
@jwt_required()
def get_all_posts():
    try:
        current_user = get_jwt_identity()

        user_ref = users_ref.document(current_user)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return jsonify({"error": "User not found"}), 404

        user_data = user_doc.to_dict()
        email = user_data.get('email')
        
        # Fetch all posts from Firestore
        posts_ref = db.collection('posts')
        posts = posts_ref.stream()

        posts_list = []

        for post in posts:
            post_data = post.to_dict()
            
            # Fetch the user's details
            user_ref = users_ref.document(post_data.get('username'))
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                first_name = user_data.get('first_name', '')
                last_name = user_data.get('last_name', '')
                profile_image = user_data.get('profile_image', '')
            else:
                first_name = ''
                last_name = ''

            # Calculate time ago
            timestamp_str = post_data.get('timestamp', None)
            post_timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
            time_ago_str = time_ago(post_timestamp)
            
            # Create post response data
            post_response = {
                'likes': post_data.get('likes'),
                'comments': post_data.get('comments'),
                'post_id': post.id,
                'username': post_data.get('username'),
                'first_name': first_name,
                'last_name': last_name,
                'profile_image': profile_image,
                'content': post_data.get('content'),
                'image_url': post_data.get('image_url', None),
                'time_ago': time_ago_str,
                'time_stamp': post_timestamp,
                'isLiked': current_user in post_data.get('likes'),
                'this_user': post_data.get('username') == current_user
            }

            posts_list.append(post_response)
        
        # Sort posts by timestamp in descending order
        posts_list.sort(key=lambda x: x['time_stamp'], reverse=True)

        return jsonify({"posts" : posts_list, "email": email, "username": current_user}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/posts/following', methods=['GET'])
@jwt_required()
def get_following_posts():
    try:
        current_user = get_jwt_identity()

        # Retrieve the current user's document
        user_ref = users_ref.document(current_user)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return jsonify({"error": "User not found"}), 404

        user_data = user_doc.to_dict()

        # Get the list of users the current user is following
        following_users = user_data.get('following', [])
        email = user_data.get('email')
        
        # Add the current user to the list of users to include their posts
        following_users.append(current_user)

        # Fetch posts from the users in the following list
        posts_ref = db.collection('posts')
        posts_query = posts_ref.where('username', 'in', following_users).stream()

        posts_list = []
        for post in posts_query:
            post_data = post.to_dict()

            # Fetch the user's details for each post
            user_ref = users_ref.document(post_data.get('username'))
            user_doc = user_ref.get()
            
            if user_doc.exists:
                user_data = user_doc.to_dict()
                first_name = user_data.get('first_name', '')
                last_name = user_data.get('last_name', '')
                profile_image = user_data.get('profile_image', '')
            else:
                first_name = ''
                last_name = ''
                profile_image = ''
            
            # Calculate time ago
            timestamp_str = post_data.get('timestamp', None)
            post_timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
            time_ago_str = time_ago(post_timestamp)

            # Create post response data
            post_response = {
                'likes': post_data.get('likes'),
                'comments': post_data.get('comments'),
                'post_id': post.id,
                'username': post_data.get('username'),
                'first_name': first_name,
                'last_name': last_name,
                'profile_image': profile_image,
                'content': post_data.get('content'),
                'image_url': post_data.get('image_url', None),
                'time_stamp': post_timestamp,
                'time_ago': time_ago_str,
                'isLiked': current_user in post_data.get('likes'),
                'this_user': post_data.get('username') == current_user
            }

            posts_list.append(post_response)

        # Sort posts by timestamp in descending order
        posts_list.sort(key=lambda x: x['time_stamp'], reverse=True)

        return jsonify({"posts" : posts_list, "email": email, "username": current_user}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/follow_user', methods=['POST'])
@jwt_required()
def follow_user():
    current_user = get_jwt_identity()
    # Get the request data
    data = request.get_json()
    username = data.get('username', '')

    if current_user == username:
        return jsonify({'success': False, 'message': 'You cannot follow yourself'}), 400

    try:
        # Get references to the current user's and target user's documents
        current_user_ref = users_ref.document(current_user)
        target_user_ref = users_ref.document(username)
        
        # Fetch the current user's document
        current_user_doc = current_user_ref.get()
        if not current_user_doc.exists:
            return jsonify({'success': False, 'message': 'Current user not found'}), 404
        
        # Fetch the target user's document
        target_user_doc = target_user_ref.get()
        if not target_user_doc.exists:
            return jsonify({'success': False, 'message': 'Target user not found'}), 404
        
        current_user_data = current_user_doc.to_dict()
        target_user_data = target_user_doc.to_dict()
        
        # Check if the current user is already following the target user
        if username in current_user_data.get('following', []):
            return jsonify({'success': False, 'message': 'You are already following this user'}), 400
        
        # Add the target user to the current user's following list
        current_user_ref.update({
            'following': current_user_data.get('following', []) + [username]
        })

        # Add the current user to the target user's followers list
        target_user_ref.update({
            'followers': target_user_data.get('followers', []) + [current_user]
        })

        return jsonify({'success': True, 'message': 'Successfully followed user'}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/unfollow_user', methods=['POST'])
@jwt_required()
def unfollow_user():
    try:
        current_user = get_jwt_identity()
        data = request.get_json()
        target_username = data.get('username')

        if not target_username:
            return jsonify({'success': False, 'message': 'Target username is required'}), 400

        # Fetch the current user and target user documents
        current_user_ref = users_ref.document(current_user)
        target_user_ref = users_ref.document(target_username)

        current_user_doc = current_user_ref.get()
        target_user_doc = target_user_ref.get()

        if not target_user_doc.exists:
            return jsonify({'success': False, 'message': 'Target user not found'}), 404

        if current_user == target_username:
            return jsonify({'success': False, 'message': 'Cannot unfollow yourself'}), 400

        # Update the following list for the current user
        current_user_data = current_user_doc.to_dict()
        following_list = current_user_data.get('following', [])
        if target_username in following_list:
            following_list.remove(target_username)
            current_user_ref.update({'following': following_list})

        # Update the followers list for the target user
        target_user_data = target_user_doc.to_dict()
        followers_list = target_user_data.get('followers', [])
        if current_user in followers_list:
            followers_list.remove(current_user)
            target_user_ref.update({'followers': followers_list})

        return jsonify({'success': True, 'message': f'Unfollowed {target_username}'}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/like_post', methods=['POST'])
@jwt_required()
def like_post():
    current_user = get_jwt_identity()
    data = request.get_json()
    post_id = data.get('post_id')

    try:
        # Get reference to the post document
        post_ref = db.collection('posts').document(post_id)
        post_doc = post_ref.get()

        if not post_doc.exists:
            return jsonify({'success': False, 'message': 'Post not found'}), 404

        post_data = post_doc.to_dict()
        likes_list = post_data.get('likes', [])

        # Check if the current user has already liked the post
        if current_user in likes_list:
            return jsonify({'success': False, 'message': 'You have already liked this post'}), 400

        # Add the current user to the likes list
        likes_list.append(current_user)

        # Update the post document with the new likes list
        post_ref.update({'likes': likes_list})

        # Fetch the updated post document to get the number of likes
        updated_post_doc = post_ref.get()
        updated_post_data = updated_post_doc.to_dict()
        updated_likes_list = updated_post_data.get('likes', [])
        num_likes = len(updated_likes_list)

        # Get the user who created the post
        post_owner_id = post_data.get('username')  # Assuming 'user_id' is stored in the post document
        user_ref = db.collection('users').document(post_owner_id)
        user_doc = user_ref.get()

        if user_doc.exists:
            user_data = user_doc.to_dict()
            fcm_token = user_data.get('fcmtoken')  # Assuming the user's FCM token is stored in the user document

            print(fcm_token)

            if fcm_token:
                # Send push notification
                message = messaging.Message(
                    notification=messaging.Notification(
                        title='Your Post Was Liked!',
                        body=f'Your post has been liked by {current_user}.'
                    ),
                    token=fcm_token
                )
                response = messaging.send(message)
                print('Successfully sent message:', response)

        return jsonify({'success': True, 'message': 'Post liked successfully', "count": num_likes}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/unlike_post', methods=['POST'])
@jwt_required()
def unlike_post():
    current_user = get_jwt_identity()
    data = request.get_json()
    post_id = data.get('post_id')
    
    try:
        # Get the post document
        post_ref = db.collection('posts').document(post_id)
        post_doc = post_ref.get()
        
        if not post_doc.exists:
            return jsonify({'success': False, 'message': 'Post not found'}), 404
        
        post_data = post_doc.to_dict()
        likes = post_data.get('likes', [])
        
        # Check if the user has already liked the post
        if current_user not in likes:
            return jsonify({'success': False, 'message': 'You have not liked this post'}), 400
        
        # Remove the user from the likes list
        likes.remove(current_user)
        post_ref.update({'likes': likes})

        # Fetch the updated post document to get the number of likes
        updated_post_doc = post_ref.get()
        updated_post_data = updated_post_doc.to_dict()
        updated_likes_list = updated_post_data.get('likes', [])
        num_likes = len(updated_likes_list)
        
        return jsonify({'success': True, 'message': 'Post unliked successfully', 'count': num_likes}), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/like_comment', methods=['POST'])
@jwt_required()
def like_comment():
    current_user = get_jwt_identity()
    data = request.get_json()
    comment_id = data.get('comment_id')

    try:
        # Get reference to the post document
        comment_ref = db.collection('comments').document(comment_id)
        comment_doc = comment_ref.get()

        if not comment_doc.exists:
            return jsonify({'success': False, 'message': 'Comment not found'}), 404

        comment_data = comment_doc.to_dict()
        likes_list = comment_data.get('likes', [])

        # Check if the current user has already liked the post
        if current_user in likes_list:
            return jsonify({'success': False, 'message': 'You have already liked this comment'}), 400

        # Add the current user to the likes list
        likes_list.append(current_user)

        # Update the post document with the new likes list
        comment_ref.update({'likes': likes_list})

        # Fetch the updated post document to get the number of likes
        updated_comment_doc = comment_ref.get()
        updated_comment_data = updated_comment_doc.to_dict()
        updated_likes_list = updated_comment_data.get('likes', [])
        num_likes = len(updated_likes_list)

        # # Get the user who created the post
        # post_owner_id = post_data.get('username')  # Assuming 'user_id' is stored in the post document
        # user_ref = db.collection('users').document(post_owner_id)
        # user_doc = user_ref.get()

        # if user_doc.exists:
        #     user_data = user_doc.to_dict()
        #     fcm_token = user_data.get('fcm_token')  # Assuming the user's FCM token is stored in the user document

        #     if fcm_token:
        #         # Send push notification
        #         message = messaging.Message(
        #             notification=messaging.Notification(
        #                 title='Your Post Was Liked!',
        #                 body=f'Your post has been liked by {current_user}.'
        #             ),
        #             token=fcm_token
        #         )
        #         response = messaging.send(message)
        #         print('Successfully sent message:', response)

        return jsonify({'success': True, 'message': 'Comment liked successfully', "count": num_likes}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/unlike_comment', methods=['POST'])
@jwt_required()
def unlike_comment():
    current_user = get_jwt_identity()
    data = request.get_json()
    comment_id = data.get('comment_id')
    
    try:
        # Get the post document
        comment_ref = db.collection('comments').document(comment_id)
        comment_doc = comment_ref.get()
        
        if not comment_doc.exists:
            return jsonify({'success': False, 'message': 'Comment not found'}), 404
        
        comment_data = comment_doc.to_dict()
        likes = comment_data.get('likes', [])
        
        # Check if the user has already liked the post
        if current_user not in likes:
            return jsonify({'success': False, 'message': 'You have not liked this comment'}), 400
        
        # Remove the user from the likes list
        likes.remove(current_user)
        comment_ref.update({'likes': likes})

        # Fetch the updated post document to get the number of likes
        updated_comment_doc = comment_ref.get()
        updated_comment_data = updated_comment_doc.to_dict()
        updated_likes_list = updated_comment_data.get('likes', [])
        num_likes = len(updated_likes_list)
        
        return jsonify({'success': True, 'message': 'Comment unliked successfully', 'count': num_likes}), 200
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/posts/likes/<post_id>', methods=['GET'])
@jwt_required()
def get_post_likes(post_id):
    try:
        current_user = get_jwt_identity()

        # Fetch the post document
        post_ref = db.collection('posts').document(post_id)
        post_doc = post_ref.get()

        if not post_doc.exists:
            return jsonify({"error": "Post not found"}), 404

        post_data = post_doc.to_dict()
        likes = post_data.get('likes', [])

        if not likes:
            return jsonify([]), 200

        # Fetch the user details for all users who liked the post
        users_ref = db.collection('users')
        liked_users = [users_ref.document(user).get().to_dict() for user in likes if users_ref.document(user).get().exists]

        # Check if the current user is following these users
        user_ref = users_ref.document(current_user)
        user_doc = user_ref.get()
        
        if not user_doc.exists:
            return jsonify({"error": "User not found"}), 404

        user_data = user_doc.to_dict()
        following_users = set(user_data.get('following', []))

        response = []
        for user in liked_users:
            user_info = {
                "username": user.get("username"),
                "first_name": user.get("first_name"),
                "last_name": user.get("last_name"),
                "profile_image": user.get("profile_image"),
                "isFollowing": user.get("username") in following_users,
                "this_user": user.get("username") == current_user
            }
            response.append(user_info)

        # Sort the list to have the current user at the front if they liked the post
        response.sort(key=lambda x: (not x['this_user'], x['username']))

        return jsonify(response), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/create_comment', methods=['POST'])
@jwt_required()
def create_comment():
    try:
        # Extract data from request
        username = get_jwt_identity()
        post_id = request.form.get('post_id')
        message = request.form.get('message')
        image_url = ""
        likes = []  # Initialize as an empty list
        
        # Validate required fields
        if not all([post_id, message]):
            return jsonify({'error': 'Missing required fields'}), 400

        if 'file' in request.files:
            file = request.files['file']
            if file.filename == '':
                pass
            else:
                # Upload the image to Firebase Storage
                blob = bucket.blob(f'post_images/{file.filename}')
                blob.upload_from_file(file)

                # Make the file publicly accessible
                blob.make_public()
                image_url = blob.public_url
        
        # Create a new comment in the 'comments' collection
        comment_data = {
            'username': username,
            'message': message,
            'likes': likes,
            'image_url': image_url,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        
        comment_ref = db.collection('comments').document()
        comment_ref.set(comment_data)
        comment_id = comment_ref.id

        # Add the new comment ID to the post's comments list
        post_ref = db.collection('posts').document(post_id)
        post_ref.update({
            'comments': firestore.ArrayUnion([comment_id])
        })

        return jsonify({'id': comment_id, 'status': 'Comment created successfully'}), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/posts/<post_id>', methods=['GET'])
@jwt_required()
def get_post_with_comments(post_id):
    try:
        current_user = get_jwt_identity()
        
        # Fetch the post document
        post_ref = db.collection('posts').document(post_id)
        post_doc = post_ref.get()

        if not post_doc.exists:
            return jsonify({'error': 'Post not found'}), 404
        
        post_data = post_doc.to_dict()

        # Fetch the user's details for each post
        user_ref = users_ref.document(post_data.get('username'))
        user_doc = user_ref.get()
        
        if user_doc.exists:
            user_data = user_doc.to_dict()
            first_name = user_data.get('first_name', '')
            last_name = user_data.get('last_name', '')
            profile_image = user_data.get('profile_image', '')
        else:
            first_name = ''
            last_name = ''
            profile_image = ''
        
        # Calculate time ago
        timestamp_str = post_data.get('timestamp', None)
        post_timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
        time_ago_str = time_ago(post_timestamp)

        # Create post response data
        post_response = {
            'post_id': post_id,
            'likes': post_data.get('likes', []),
            'comments': post_data.get('comments', []),
            'username': post_data.get('username'),
            'first_name': first_name,
            'last_name': last_name,
            'profile_image': profile_image,
            'content': post_data.get('content'),
            'image_url': post_data.get('image_url', None),
            'time_stamp': post_timestamp,
            'time_ago': time_ago_str,
            'isLiked': current_user in post_data.get('likes'),
            'this_user': post_data.get('username') == current_user
        }
        
        
        # Fetch comments
        comments = post_data.get('comments', [])
        comments_details = []
        
        for comment_id in comments:
            comment_ref = db.collection('comments').document(comment_id)
            comment_doc = comment_ref.get()
            
            if comment_doc.exists:
                comment_data = comment_doc.to_dict()
                
                # Fetch commenter's details
                commenter_ref = users_ref.document(comment_data.get('username'))
                commenter_doc = commenter_ref.get()
                
                if commenter_doc.exists:
                    commenter_data = commenter_doc.to_dict()
                    commenter_first_name = commenter_data.get('first_name', '')
                    commenter_last_name = commenter_data.get('last_name', '')
                    commenter_profile_image = commenter_data.get('profile_image', '')
                else:
                    commenter_first_name = ''
                    commenter_last_name = ''
                    commenter_profile_image = ''
                
                # Comment response data
                comment_response = {
                    'comment_id': comment_id,
                    'likes': comment_data.get('likes', []),
                    'username': comment_data.get('username'),
                    'first_name': commenter_first_name,
                    'last_name': commenter_last_name,
                    'profile_image': commenter_profile_image,
                    'message': comment_data.get('message', ''),
                    'comment_image': comment_data.get('image_url', None),
                    'isLiked': current_user in comment_data.get('likes', []),
                    'this_user': comment_data.get('username') == current_user
                }
                
                comments_details.append(comment_response)
        
        post_response['comment_obj'] = comments_details
        
        return jsonify(post_response), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)