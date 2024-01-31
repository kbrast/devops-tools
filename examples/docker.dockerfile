# Create a Dockerfile that defines how to build your image
cat > Dockerfile << EOF
# Use a base image with the required runtime
FROM node:14-alpine

# Copy your code to the container
COPY . /app

# Set the working directory
WORKDIR /app

# Install the dependencies
RUN npm install

# Expose the port that your application listens on
EXPOSE 3000

# Define the command to run your application
CMD ["node", "index.js"]
EOF

# Build your image with a tag
docker build -t yourname/yourapp:latest .

# Run your image in a container
docker run -d -p 3000:3000 yourname/yourapp:latest

# Push your image to the remote server
docker push yourname/yourapp:latest