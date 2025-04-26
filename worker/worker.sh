#!/bin/bash
set -e

#Step 1 - install curl
apt-get update && apt-get install -y curl

#Step 2 - wait for Prefect API server to be up and running
echo "Waiting for Prefect API to become available..."
until curl -s http://prefect-server:4200/api/health > /dev/null; do
  echo "Waiting for Prefect server..."
  sleep 2
done

#Step 3 - Create Workpool
echo "http://prefect-server:4200/api/health -> $(curl -s http://prefect-server:4200/api/health)"
echo "Prefect Server is up... Creating or updating work pool..."
prefect work-pool create ${PREFECT_WORK_POOL_NAME} --type process || true

#Step 4 - Start the Worker
echo "Starting Prefect worker for ${PREFECT_WORK_POOL_NAME}..."
mkdir -p /var/log/
prefect worker start --pool ${PREFECT_WORK_POOL_NAME} > /var/log/prefect_worker.log 2>&1 &

# Step 5 - Start the loop to read flows and their corresponding yaml files every minute from ./flows directory
echo "Watching /opt/prefect/flows for new deployments..."

cd /opt/prefect/flows

while true; do
  echo "Checking for new deployments at $(date)..."

  # Find all prefect.yaml files recursively
  find . -name "prefect.yaml" | while read -r yaml_file; do
    dir=$(dirname "$yaml_file")

    # Check if there's at least one Python file in the same directory
    py_file=$(find "$dir" -maxdepth 1 -name "*.py" | head -n 1)

    if [ -n "$py_file" ]; then
      echo "Deploying from $yaml_file in $dir"
      (cd "$dir" && prefect deploy || echo "Deployment failed in $dir")
    else
      echo "No Python flow file found in $dir, skipping..."
    fi
  done

  echo "Waiting for 60 seconds before next check..."
  sleep 60
done


