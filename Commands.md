# Start services
docker compose --env-file .env up --build

source venv/Scripts/activate

For the flow to be registered and the image to be build properly using --build argument in the above command the Docker file should be named Dockerfile without any modifications, else it will not pick up the build step. -- not correct

building docker image:
docker build -t custom-prefect-worker:latest .

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/x6y0bg1fdtfxv99b2mvgp08mp
python /flows/deploy_etl.py &&

winpty docker exec -it custom-prefect-server //bin/bash

```

Start a run for a prefect deployment:
prefect deployment run 'demo-etl-flow/demo-etl-flow-deployment'