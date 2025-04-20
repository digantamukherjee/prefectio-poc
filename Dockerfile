FROM prefecthq/prefect:3.0.8-python3.10
RUN apt-get update && apt-get install -y curl

# Copy your flow and deployment script
WORKDIR /flows
COPY ./flows /flows

# Install dependencies (if you have requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt

# Install docker extras for docker workers
# RUN pip install "prefect[docker]"
