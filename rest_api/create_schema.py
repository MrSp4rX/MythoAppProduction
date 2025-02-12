from pymongo import MongoClient
from datetime import datetime

client = MongoClient("mongodb+srv://sshourya948:SwatiLovesShaurya@otpbot.bfy6u.mongodb.net/")
db = client["mytho_app_database"]

users_collection = db["users"]
users_schema = {
    "_id": "ObjectId",
    "username": "string",
    "email": "string",
    "password_hash": "string",
    "avatar": "string",
    "reading_history": [
        {
            "novel_id": "ObjectId",
            "last_read_chapter": "ObjectId",
            "last_read_at": "datetime"
        }
    ],
    "bookmarks": ["ObjectId"],
    "created_at": "datetime",
}
# users_collection.insert_one(
#     {
#     "username": "mrsp4rx",
#     "email": "sshourya948@gmail.com",
#     "password_hash": "123456",
#     "isVerified": False,
#     "avatar": "https://avatars.githubusercontent.com/u/71897067?v=4",
#     "reading_history": [
#         {
#             "novel_id": "",
#             "last_read_chapter": "",
#             "last_read_at": ""
#         }
#     ],
#     "bookmarks": [],
#     "created_at": "",
# }
# )


novels_collection = db["novels"]
novels_schema = {
    "_id": "ObjectId",
    "title": "string",
    "author": "string",
    "description": "string",
    "genres": ["string"], 
    "cover_image": "string",  
    "total_chapters": "int",
    "status": "string",  
    "views": "int",
    "ratings": {
        "average_rating": "float",
        "total_reviews": "int"
    },
    "created_at": "datetime",
}
# novels_collection.insert_one(
#     {
#     "title": "The Last Signal",
#     "author": "Shaurya Pratap Singh",
#     "description": """Ethan sat alone in the control room, the hum of the failing space station echoing around him. Earth was a distant blue dot beyond the fractured window, and the last distress signal he sent had gone unanswered.  

# He checked the oxygen levels—twelve hours left. His crewmates were gone, lost to the meteor storm that had left the station crippled. Only he remained, drifting in silence.  

# Then, a flicker on the monitor. A signal. Faint but unmistakable.  

# "Ethan, hold on. We're coming."

# Relief flooded him, but then—static. The signal cut off. Was it real, or was his oxygen-starved mind playing tricks? He clenched his fists, fighting the creeping despair. He had to believe.  

# Time stretched. The station groaned under its own weight, its structure failing. And just when the silence became unbearable, a shadow passed over the viewport. A ship.  

# His radio crackled. "Ethan, open the airlock. We've got you."

# With the last of his strength, he activated the hatch. As the rescue team pulled him aboard, the station crumbled behind him, swallowed by the void.  

# Ethan exhaled. He was going home.""",
#     "genres": ["scifi", "thriller"], 
#     "cover_image": "https://play-lh.googleusercontent.com/8NamJF7rYT0CpBATq8YeeIlo46F-yGpGsgOl0yfXXmFP0KwKOsNWrLLNo405HdExVOL07Qhzv6zqVDKusiU=w240-h480-rw",
#     "total_chapters": "1",
#     "status": "reading",  
#     "views": "1832",
#     "ratings": {
#         "average_rating": "4.5",
#         "total_reviews": "650"
#     },
#     "created_at": "",
# }
# )

chapters_collection = db["chapters"]
chapters_schema = {
    "_id": "ObjectId",
    "novel_id": "ObjectId",
    "chapter_number": "int",
    "title": "string",
    "content": """string""",
    "word_count": "int",
    "published_at": "datetime"
}
# chapters_collection.insert_one(
#     {
#     "novel_id": "",
#     "chapter_number": "1",
#     "title": "Silence in the Void",
#     "content": """Ethan Carter floated weightlessly in the dim control room, the flickering emergency lights casting long shadows across the cracked metal walls. The space station, Aurora-7, had been silent for twenty-two hours—silent except for the low hum of failing life support and the occasional creaks of metal straining against the vacuum.

# He reached for the console, his gloved fingers hovering over the communication panel. The last distress signal had been sent six hours ago. No response. He stared at the monitor, hoping, praying for a flicker—any sign that someone was listening.

# Nothing.

# His oxygen levels were dropping, the tank indicator glowing an ominous red. Twelve hours left. He inhaled deeply, trying to steady his thoughts, but the weight of loneliness pressed against his chest. His crewmates were gone—Mira, Jackson, Lee. One moment, they had been preparing for a routine diagnostic outside the station. The next, the meteor storm had torn through their hull, taking them with it.

# Ethan clenched his jaw. Survive. That was all that mattered now.

# He pushed off the console, floating toward the supply cabinet. If no one was coming, he needed to find another way.

# Then, the radio crackled. A voice—faint, distorted.

# "Ethan... do you copy?"

# His heart pounded. He grabbed the receiver.

# "This is Ethan Carter! Who is this?"

# Static. Then, a whisper.

# "Hold on. We're coming."

# The line went dead.""",
#     "word_count": "225",
#     "published_at": ""
# }
# )


bookmarks_collection = db["bookmarks"]
bookmarks_schema = {
    "_id": "ObjectId",
    "user_id": "ObjectId",
    "novel_id": "ObjectId",
    "chapter_id": "ObjectId",
    "position": "int",
    "added_at": "datetime"
}
# bookmarks_collection.insert_one(
#     {
#     "user_id": "",
#     "novel_id": "",
#     "chapter_id": "",
#     "position": "0",
#     "added_at": "",
# }
# )


reviews_collection = db["reviews"]
reviews_schema = {
    "_id": "ObjectId",
    "user_id": "ObjectId",
    "novel_id": "ObjectId",
    "rating": "float",
    "review_text": "string",
    "created_at": "datetime"
}
# reviews_collection.insert_one(
#     {
#     "user_id": "",
#     "novel_id": "",
#     "rating": "4.5",
#     "review_text": "Great story! Can't wait for the next chapter.",
#     "created_at": "",
# }
# )

sessions_collection = db["sessions"]
session_schema = {
    "_id": "ObjectId",
    "user_id": "ObjectId",
    "token": "jwt_token_here",
    "jti": "unique_session_id",
    "created_at": "timestamp"
}
# sessions_collection.insert_one(
#     {
#     "user_id": "mrsp4rx",
#     "token": "test_token",
#     "jti": "test_jti",
#     "created_at": "",
# }
# )

print("Database schema is ready!")
