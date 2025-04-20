#!/bin/bash
set -e
apt-get update && apt-get install -y curl
echo "Waiting for Prefect API to become available..."
until curl -s http://prefect-server:4200/api/health > /dev/null; do
  echo "Waiting for Prefect server..."
  sleep 2
done

# until python3 -c "
# import sys
# import http.client
# try:
#     conn = http.client.HTTPConnection('prefect-server', 4200)
#     conn.request('GET', '/api/health')
#     res = conn.getresponse()
#     sys.exit(0 if res.status == 200 else 1)
# except:
#     sys.exit(1)
# "; do
#   echo "Waiting for Prefect server..."
#   sleep 2
# done
echo $(curl -s http://prefect-server:4200/api/health)
echo "Prefect Server is up... Creating or updating work pool..."
prefect work-pool create ${PREFECT_WORK_POOL_NAME} --type process || true

echo "Registering deployments using prefect.yaml..."
cd /opt/prefect/flows

# for yml in */prefect.yaml *.yaml; do
#   if [ -f "$yml" ]; then
#     echo "Deploying from $yml"
#     prefect deploy --name "$(basename "$yml" .yaml)" --skip-upload --directory "$(dirname "$yml")"
#   fi
# done

# for yml in $(find . -name "prefect.yaml"); do
#   dir=$(dirname "$yml")
#   echo "Deploying from $yml"
#   (cd "$dir" && prefect deploy)
# done

prefect deploy --name etl-deployment --pool process-pool etl_flow.py:etl

echo "Starting Prefect worker for ${PREFECT_WORK_POOL_NAME}..."
prefect worker start --pool ${PREFECT_WORK_POOL_NAME}
