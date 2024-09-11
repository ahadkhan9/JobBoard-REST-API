#!/bin/bash

# Define variables
PROJECT_DIR="path to your project dir"
DOCKER_IMAGE_NAME="job-post-rest-api:latest"
TAR_FILE="job-post-rest-api.tar"
SERVER_USER="root"
SERVER_IP="Enter Your Server IP aadrs"
SERVER_PROJECT_DIR="/root/projects/Spring-Learning"
SSH_KEY="Enter Your SSH key"  # Ensure this key has the correct permissions (chmod 600)

# Step 1: Build the JAR file locally
echo "Building the project with Maven..."
cd "$PROJECT_DIR" || exit
mvn clean package -DskipTests

# Verify the build was successful
if [ ! -f "target/FirstJobApp-0.0.1-SNAPSHOT.jar" ]; then
    echo "Build failed! JAR file not found."
    exit 1
fi

# Step 2: Build the Docker image
echo "Building the Docker image..."
docker build -t "$DOCKER_IMAGE_NAME" .

# Step 3: Save the Docker image to a tar file
echo "Saving the Docker image to a tar file..."
docker save -o "$TAR_FILE" "$DOCKER_IMAGE_NAME"

# Step 4: Transfer the tar file to the server
echo "Transferring the tar file to the server..."
scp -i "$SSH_KEY" "$TAR_FILE" "$SERVER_USER@$SERVER_IP:$SERVER_PROJECT_DIR/"

# Step 5: Load the Docker image on the server
echo "Loading the Docker image on the server..."
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_IP" "cd $SERVER_PROJECT_DIR && docker load -i $TAR_FILE"

# Step 6: Run the Docker container on the server
echo "Running the Docker container on the server..."
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_IP" "docker run -d -p 8080:8080 --name job-post-rest-api $DOCKER_IMAGE_NAME"

# Confirm deployment
echo "Deployment completed."
