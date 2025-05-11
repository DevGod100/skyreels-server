# skyreels-server/Dockerfile
# Use Python slim base
FROM python:3.10-slim

# install git, build essentials and OS libs (libGL, glib threading)
RUN apt-get update \
    && apt-get install -y \
       git \
       build-essential \
       libgl1-mesa-glx \
       libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# set working directory
WORKDIR /app

# clone SkyReels V2
RUN git clone https://github.com/SkyworkAI/SkyReels-V2.git /app/SkyReels-V2

# remove optional flash_attn to skip build errors
RUN sed -i '/flash_attn/d' /app/SkyReels-V2/requirements.txt

# install CPU-only PyTorch and torchvision from official PyTorch wheels
RUN pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    torch==2.5.1 torchvision==0.20.1

# install SkyReels-V2 requirements
RUN pip install --no-cache-dir -r /app/SkyReels-V2/requirements.txt

# install FastAPI and Uvicorn
RUN pip install --no-cache-dir fastapi uvicorn[standard]

# set PYTHONPATH
ENV PYTHONPATH=/app/SkyReels-V2

# copy server code
COPY server.py /app/server.py

# expose port
EXPOSE 8000

# start Uvicorn
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
