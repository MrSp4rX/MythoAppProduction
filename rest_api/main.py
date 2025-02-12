from flask import Flask, request, jsonify
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import uuid
from functools import wraps
import random
from helper import send_otp

# Flask App Initialization
app = Flask(__name__)
app.config['SECRET_KEY'] = 'mysecretkey123'

# MongoDB Connection
client = MongoClient("mongodb+srv://sshourya948:SwatiLovesShaurya@otpbot.bfy6u.mongodb.net/")
db = client["mytho_app_database"]
users_collection = db["users"]
sessions_collection = db["sessions"]
otp_collection = db["otp"]

# Helper function to create JWT Token
def create_access_token(user_id):
    expiration = datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    jti = str(uuid.uuid4())
    token = jwt.encode({"sub": user_id, "exp": expiration, "jti": jti}, 
                        app.config['SECRET_KEY'], algorithm="HS256")
    sessions_collection.update_one({"user_id": user_id}, 
                                   {"$set": {"token": token, "jti": jti, "created_at": datetime.datetime.utcnow()}},
                                   upsert=True)
    return token

# Authentication Middleware
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'message': 'Token is missing'}), 401
        try:
            token = token.split("Bearer ")[1]
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            user_id = data['sub']
        except:
            return jsonify({'message': 'Invalid token'}), 401
        return f(user_id, *args, **kwargs)
    return decorated

# Signup Route
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    existing_user = users_collection.find_one({"username": data['username']})
    if existing_user:
        return jsonify({"detail": "Username already taken"}), 400
    hashed_password = generate_password_hash(data['password'])
    new_user = {
        "username": data['username'],
        "email": data['email'],
        "password_hash": hashed_password,
        "phone_number": data['phone_number'],
        "isVerified": data.get('isVerified', False),
        "created_at": datetime.datetime.utcnow()
    }
    users_collection.insert_one(new_user)
    return jsonify({"message": "User registered successfully"})

# Login Route
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    print(data)
    user = users_collection.find_one({"username": data['username']})
    if user and check_password_hash(user['password_hash'], data['password']):
        token = create_access_token(str(user['_id']))
        return jsonify({"access_token": token, "token_type": "bearer"})
    return jsonify({"detail": "Invalid credentials"}), 400

# Logout Route
@app.route('/logout', methods=['POST'])
@token_required
def logout(user_id):
    sessions_collection.delete_one({"user_id": user_id})
    return jsonify({"message": "Logged out successfully"})

# Protected Route Example
@app.route('/protected', methods=['GET'])
@token_required
def protected_route(user_id):
    user = users_collection.find_one({"_id": user_id})
    if not user:
        return jsonify({"message": "User not found"}), 404
    return jsonify({"message": f"Hello, {user['username']}! You are authenticated."})

# Send OTP Route
@app.route('/send-otp', methods=['POST'])
def sendotp():
    data = request.json
    email = data.get("email")
    if not email:
        return jsonify({"detail": "Phone number or email is required"}), 400
    
    otp = random.randint(100000, 999999)
    otp_collection.update_one({"email": email}, 
                              {"$set": {"otp": otp, "created_at": datetime.datetime.utcnow()}}, 
                              upsert=True)
    send_otp(email, otp)
    return jsonify({"message": f"OTP sent to {email}", "otp": otp})

if __name__ == '__main__':
    app.run(debug=False, use_reloader=False)
