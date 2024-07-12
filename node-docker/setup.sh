#!/bin/bash

# Convert Windows path to Unix-style path and remove any trailing backslash
project_path=$(echo "$1" | sed 's/\\/\//g' | sed 's/\/$//')

# Check if project name is provided as argument
if [ -z "$2" ]
then
  echo "No project name provided. Using default name 'appname'."
  project_name="appname"
else
  project_name="$2"
fi

# Create main directory
mkdir -p "$project_path"
cd "$project_path" || exit
# mkdir "$project_name"
# cd "$project_name" || exit

# Run npm init --yes

# Create subdirectories
npm init --yes


mkdir app db middlewares routes utils

mv package.json ../"$project_name"/app/package.json


echo '/"$project_name"/app/'

# move the docker files
mv ../app/Dockerfile ../"$project_name"/app/Dockerfile

mv ../app/Dockerfile.dev ../"$project_name"/app/Dockerfile.dev

mv ../postgres/Dockerfile ../"$project_name"/postgres/Dockerfile

mv ../db/postgres.js ../"$project_name"/db/postgres.js

mv ../db/redis.js ../"$project_name"/db/redis.js


mv ../docker-compose.yml ../"$project_name"/docker-compose.yml

mv ../docker-compose.dev.yml ../"$project_name"/docker-compose.dev.yml

rm -rf ../app

rm -rf ../postgres

rm -rf ../db




# touch Dockerfile Dockerfile.dev

# Create Postgres directory and files if enabled
if [ "$3" == "y" ]
then
  mkdir postgres
  cd postgres || exit
  mkdir scripts
  touch Dockerfile
  cd ..
fi

# Create Redis directory and files if enabled
if [ "$4" == "y" ]
then
  mkdir redis
fi

echo "Project structure created successfully!"

rm -rf ../setup.sh
