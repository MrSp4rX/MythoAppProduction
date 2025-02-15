from flask import Flask, request, jsonify
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import uuid
from functools import wraps
import random
from helper import send_otp

app = Flask(__name__)
app.config['SECRET_KEY'] = 'mysecretkey123'

client = MongoClient("mongodb+srv://sshourya948:SwatiLovesShaurya@otpbot.bfy6u.mongodb.net/")
db = client["mytho_app_database"]
users_collection = db["users"]
sessions_collection = db["sessions"]
otp_collection = db["otp"]
books_collection = db["novels"]

def create_access_token(user_id):
    expiration = datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    jti = str(uuid.uuid4())
    token = jwt.encode({"sub": user_id, "exp": expiration, "jti": jti}, 
                        app.config['SECRET_KEY'], algorithm="HS256")
    sessions_collection.update_one({"user_id": user_id}, 
                                   {"$set": {"token": token, "jti": jti, "created_at": datetime.datetime.utcnow()}},
                                   upsert=True)
    return token

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

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    print(data)
    user = users_collection.find_one({"username": data['username']})
    if user and check_password_hash(user['password_hash'], data['password']):
        token = create_access_token(str(user['_id']))
        return jsonify({"access_token": token, "token_type": "bearer"})
    return jsonify({"detail": "Invalid credentials"}), 400

@app.route('/logout', methods=['POST'])
@token_required
def logout(user_id):
    sessions_collection.delete_one({"user_id": user_id})
    return jsonify({"message": "Logged out successfully"})

@app.route('/protected', methods=['GET'])
@token_required
def protected_route(user_id):
    user = users_collection.find_one({"_id": user_id})
    if not user:
        return jsonify({"message": "User not found"}), 404
    return jsonify({"message": f"Hello, {user['username']}! You are authenticated."})

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


@app.route('/getBooks', methods=['GET'])
@token_required
def get_books(user_id):
    books = []
    for book in books_collection.find():
        books.append({
            "title": book['title'],
            "author": book['author'],
            "description": book['description'],
            "genres": book['genres'],
            "cover_image": book['cover_image'],
            "total_chapters": book['total_chapters'],
            "status": book['status'],
            "views": book['views'],
            "ratings": book['ratings'],
            "created_at": book['created_at']
        })
    print({"books": books})
    return jsonify({"books": books})


if __name__ == '__main__':
    app.run(debug=True, use_reloader=True)
