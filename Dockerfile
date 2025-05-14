# skyreels-server/Dockerfile
FROM python:3.10-slim

# install system deps
RUN apt-get update \
 && apt-get install -y \
      git build-essential \
      libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# pull SkyReels-V2 and strip flash_attn
RUN git clone https://github.com/SkyworkAI/SkyReels-V2.git /app/SkyReels-V2 \
 && sed -i '/flash_attn/d' /app/SkyReels-V2/requirements.txt

# tell Python where to find the SkyReels code
ENV PYTHONPATH="/app/SkyReels-V2:$PYTHONPATH"

# install CPU PyTorch wheels
RUN pip install --no-cache-dir \
      --index-url https://download.pytorch.org/whl/cpu \
      torch==2.5.1 torchvision==0.20.1

# install the rest of SkyReels dependencies
RUN pip install --no-cache-dir -r /app/SkyReels-V2/requirements.txt

# install FastAPI + Uvicorn
RUN pip install --no-cache-dir fastapi uvicorn[standard]

# copy your FastAPI server code
COPY server.py /app/server.py

EXPOSE 8000
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
