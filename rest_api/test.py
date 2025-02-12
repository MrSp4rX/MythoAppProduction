import requests

# SignUp 
url = "http://127.0.0.1:8000/signup"
data = {
    "username": "testuser2",
    "email": "sshourya948@gmail.com",
    "password": "123456",
    "phone_number": "1234567890",
    "isVerified": False
}

response = requests.post(url, json=data)


# Login
# url = "https://f548-2409-40e3-3081-ad69-1c3c-996e-c614-c6b1.ngrok-free.app/login"
# data = {
#     "username": "testuser",
#     "password": "123456"
# }

# response = requests.post(url, json=data)

# Getting Data After Getting Logged In
# response = requests.get("http://127.0.0.1:8000/protected", headers={"Authorization": f"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2N2FjNWM1MTI1MDA0ODhkMDU5OWIxNDIiLCJleHAiOjE3MzkzNTM5NjQsImp0aSI6ImMyZmY4OTA4LTA3ZDgtNDA1YS1hYTNiLTMzMTg5M2I2NjUxNyJ9.cUOz0W36X87GnF0Jn2BNF5p472ckdseQH9oJYj4r89c"})


# Logging Out
# response = requests.post("http://127.0.0.1:8000/logout", headers={"Authorization": f"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2N2FjNWM1MTI1MDA0ODhkMDU5OWIxNDIiLCJleHAiOjE3MzkzNTk3MjAsImp0aSI6Ijc4Y2VjN2ViLTZlZjUtNDY3ZS1iMjAwLTViY2FhMzIwZTljNCJ9.MdgRWVJwVVGUOLIE1uWEVQ_yjaB30YXVTeeXcaV60bE"})


print(response.json())
