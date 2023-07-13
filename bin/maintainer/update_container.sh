#!/bin/bash -e
export DOCKER_BUILDKIT=1
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build --ssh default -t movement-dev:latest -f Dockerfile.movement-dev .
docker tag movement-dev:latest public.ecr.aws/c4i6k4r8/movement-dev:latest
docker push public.ecr.aws/c4i6k4r8/movement-dev:latest

docker build --platform linux/amd64 --ssh default -t movement-dev:latest-amd -f Dockerfile.movement-dev .
docker tag movement-dev:latest public.ecr.aws/c4i6k4r8/movement-dev:latest-amd
docker push public.ecr.aws/c4i6k4r8/movement-dev:latest-amd

