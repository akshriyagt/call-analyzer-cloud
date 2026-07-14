FROM python:3.11-slim

WORKDIR /app

# faster-whisper's audio decoder needs these system libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p data/uploads data/archive data/results

# Cloud hosts inject PORT; gunicorn's long timeout lets a transcription
# request finish instead of being killed mid-way.
ENV FLASK_DEBUG=false
EXPOSE 5000
CMD gunicorn --bind 0.0.0.0:${PORT:-5000} --timeout 600 --workers 1 app:app
