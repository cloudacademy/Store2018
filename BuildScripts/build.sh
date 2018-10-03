#!/bin/bash

rebuild_services() {
  echo "=============================================="
  echo "current git commit id:"
  echo $BITBUCKET_COMMIT

  #note2
  #determine list of directories changed in latest commit
  echo "detecting updated dirs for this commit"
  UPDATED_DIRS=`git show --pretty="" --name-only $BITBUCKET_COMMIT | grep / | awk 'BEGIN {FS="/"} {print $1}' | uniq`
  echo "updated directories:"
  echo $UPDATED_DIRS

  #initialise
  UPDATED_MICROSERVICES=()

  #catalog the microservices to be built
  for FOLDER in ${UPDATED_DIRS[*]}
  do
    if [ "$FOLDER" == 'BuildScripts' ]; then
      echo "BUILD folder changed, building and publishing all microservices"
      UPDATED_MICROSERVICES+=("Store2018")
      UPDATED_MICROSERVICES+=("Services/AccountService")
      UPDATED_MICROSERVICES+=("Services/InventoryService")
      UPDATED_MICROSERVICES+=("Services/ShoppingService")
      break
    elif [ "$FOLDER" == 'Services' ]; then
      echo "SERVICES folder changed"
      SERVICE_DIRS=`find ./Services -maxdepth 1 ! -name '.*' ! -name 'Services' -type d | awk 'BEGIN {FS="/"} {print $3}' | uniq`
      echo "Adding ALL $SERVICE_DIRS to list of microservices to build"
      for SERVICE_DIR in ${SERVICE_DIRS[*]}
      do
        UPDATED_MICROSERVICES+=("Services/$SERVICE_DIR")
      done
    elif [ "$FOLDER" == 'Store2018' ]; then
      echo "Store2018 folder changed, building and pushing all microservices"
      UPDATED_MICROSERVICES+=("Store2018")
    fi
  done

  echo "list of microservices to be rebuilt:"
  for SERVICE in ${UPDATED_MICROSERVICES[*]}; do echo $SERVICE; done

  echo "performing docker login..."
  #authenticate to dockerhub for push up
  docker login --username $DOCKER_HUB_USERNAME --password $DOCKER_HUB_PASSWORD

# call docker build for each updated microservice
  for SERVICE in ${UPDATED_MICROSERVICES[*]}
  do
      echo "=================== $SERVICE: build and push ==================="
      pushd "$SERVICE"

      #establish docker image tag name
      if [ "$SERVICE" == 'Store2018' ]; then
        SERVICE_NAME=`echo "$SERVICE" | awk '{print tolower($0)}'`
      else
        SERVICE_NAME=`echo "$SERVICE" | awk 'BEGIN {FS="/"} {print tolower($2)}'`
      fi
      echo SERVICE_NAME $SERVICE_NAME

      #image name must be in format xxxxx/xxxxx:xxxxx to work with dockerhub
      IMAGE_NAME=jeremycookdev/$SERVICE_NAME:latest
      echo IMAGE_NAME $IMAGE_NAME

      #perform docker build
      docker build -t $IMAGE_NAME .
      echo "building finished!"
      #perform docker push into dockerhub
      docker push $IMAGE_NAME
      echo "pushing finished!"
      popd
  done
}

rebuild_services