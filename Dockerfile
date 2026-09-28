FROM intel/compute-runtime:latest-runtime-ubuntu24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg python3 python3-venv && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH" \
    HF_HOME=/cache/huggingface

RUN pip install --no-cache-dir --upgrade pip wheel setuptools && \
    pip install --no-cache-dir torch==2.8.0 torchaudio==2.8.0 \
      --index-url https://download.pytorch.org/whl/xpu && \
    pip install --no-cache-dir \
      transformers==4.45.2 \
      huggingface-hub==0.36.0 \
      safetensors==0.5.3 \
      numpy==1.26.4 \
      scipy==1.13.1 \
      mir_eval==0.8.2 \
      pretty_midi==0.2.10 \
      mido==1.3.3 \
      setuptools==78.1.1

RUN pip install --no-cache-dir playwright==1.58.0 && \
    python -m playwright install --with-deps --only-shell chromium && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY docker-entrypoint.sh ./

ENTRYPOINT ["/app/docker-entrypoint.sh"]
