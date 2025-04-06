# Build stage
ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION} AS base
WORKDIR /app

# Copy the requirements file first to install dependencies
COPY requirements.txt .

# Install dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy the application code into the container
COPY . .

# Runtime stage
FROM python:${PYTHON_VERSION}-slim
WORKDIR /app

# Set environment variables for the runtime
ENV PYTHONUNBUFFERED=1
ENV APP_ENV="Production"

# Copy the built application and installed dependencies from the build stage
COPY --from=base /app .

# Copy the requirements file to the runtime environment and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Run migrations
RUN python3 manage.py migrate

# Expose port 8080 to the host
EXPOSE 8080

# Define the command to run the application
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8080"]
