# Use a small Python base image
FROM python:3.11-slim

# Create app directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app
COPY app.py .

# Expose container port
EXPOSE 8080

# Run the app
CMD ["python", "app.py"]
