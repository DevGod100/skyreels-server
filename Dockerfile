# skyreels-server/Dockerfile
FROM python:3.10-slim

# install git and build essentials
RUN apt-get update \
    && apt-get install -y git build-essential \
    && rm -rf /var/lib/apt/lists/*

# set working directory
WORKDIR /app

# clone the SkyReels V2 repository
RUN git clone https://github.com/SkyworkAI/SkyReels-V2.git /app/SkyReels-V2

# remove optional flash_attn from requirements to skip build errors
RUN sed -i '/flash_attn/d' /app/SkyReels-V2/requirements.txt

# install core dependencies: torch & torchvision first
RUN pip install --no-cache-dir torch==2.5.1 torchvision==0.20.1

# install SkyReels-V2 requirements
RUN pip install --no-cache-dir -r /app/SkyReels-V2/requirements.txt

# install FastAPI and Uvicorn for our server
RUN pip install --no-cache-dir fastapi uvicorn[standard]

# set PYTHONPATH so we can import skyreels_v2_infer
ENV PYTHONPATH=/app/SkyReels-V2

# copy our FastAPI server code
COPY server.py /app/server.py

# expose the application port\ nEXPOSE 8000

# start the server
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
