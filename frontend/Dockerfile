# Use a Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy all files from the frontend folder into the container
COPY . .

# Install Python dependencies (if any)
RUN pip install --no-cache-dir -r requirements.txt || true

# Set the default command
# CMD ["python", "code.py"]

# Run the Python script and keep the container running
CMD ["sh", "-c", "python code.py & tail -f /dev/null"]
