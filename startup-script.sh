#!/bin/bash

# Install system dependencies
sudo apt-get update
sudo apt-get install -y python3 python3-pip git

# Clone your app code
git clone https://github.com/maxstrater/gallery_app.git

# Verify the correct app directory (update this path if needed)

# Install Python dependencies
sudo pip3 install -r requirements.txt
sudo pip3 install pymysql  # Ensure this is installed explicitly
sudo pip3 install gunicorn  # Add gunicorn

# Start the Flask app in the background and keep it running

# Start the app with Gunicorn (production-grade server)
nohup gunicorn -b 0.0.0.0:8080 app:app > /var/log/flask-app.log 2>&1 &