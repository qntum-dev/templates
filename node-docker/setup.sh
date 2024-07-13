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


# move the docker files
mv ../app/Dockerfile ../"$project_name"/app/Dockerfile

mv ../app/Dockerfile.dev ../"$project_name"/app/Dockerfile.dev



# mv ../docker-compose.yml ../"$project_name"/docker-compose.yml

# mv ../docker-compose.dev.yml ../"$project_name"/docker-compose.dev.yml

rm -rf ../app





# touch Dockerfile Dockerfile.dev

# Create Postgres directory and files if enabled
if [ "$3" == "y" ]
then
  mv ../db/postgres.js ../"$project_name"/db/postgres.js
  mkdir postgres
  mv ../postgres/Dockerfile ../"$project_name"/postgres/Dockerfile

  cd postgres
  mkdir scripts
  cd ..

  
fi

rm -rf ../postgres

# Create Redis directory and files if enabled
if [ "$4" == "y" ]
then
  mv ../db/redis.js ../"$project_name"/db/redis.js
  
  mkdir redis

fi

rm -rf ../db

cd ../"$project_name"

touch docker-compose.yml

cat <<EOF >> docker-compose.yml
        
services:
    server:
        build:
            context: ./src
            dockerfile: Dockerfile
        env_file:
            - ./.env
EOF

if [[ "$3" == "y" || "$4" == "y" ]]; then
    cat <<EOF >> docker-compose.yml
        depends_on:
EOF
fi

if [ "$3" == "y" ]; then
    cat <<EOF >> docker-compose.yml
            postgres:
                condition: service_healthy
EOF
fi

if [ "$4" == "y" ]; then
    cat <<EOF >> docker-compose.yml
            redis:
                condition: service_healthy
EOF
fi

cat <<EOF >> docker-compose.yml
        ports:
            - "\${PORT}:\${PORT}"
        networks:
            - app-network
EOF

if [ "$3" == "y" ]; then
    cat <<EOF >> docker-compose.yml
    postgres:
        build:
            context: ./postgres
            dockerfile: Dockerfile
        env_file:
            - ./.env
        volumes:
            - ./postgres/scripts/:/docker-entrypoint-initdb.d/
            - ./postgres/data:/var/lib/postgresql/data
        healthcheck:
            test: ["CMD-SHELL", "pg_isready"]
            interval: 10s
            timeout: 5s
            retries: 5      
        networks:
            - app-network
EOF
fi

if [ "$4" == "y" ]; then
    cat << EOF >> docker-compose.yml
    redis:
        image: redis/redis-stack-server:7.2.0-v5
        build: 
            context: ./redis
            dockerfile: Dockerfile
        env_file:
            - ./.env
        volumes:
            - ./redis/data:/data
        healthcheck:
            test: ["CMD", "redis-cli", "-p", "\${REDIS_PORT}", "ping"]
            interval: 10s
            timeout: 5s
            retries: 5
        networks:
            - app-network
EOF
fi

cat <<EOF >> docker-compose.yml
networks:
    app-network:
        driver: bridge
EOF










touch docker-compose.dev.yml

cat <<EOF >> docker-compose.dev.yml
        
services:
    server:
        build:
            context: ./src
            dockerfile: Dockerfile
        env_file:
            - ./.env.dev
EOF

if [[ "$3" == "y" || "$4" == "y" ]]; then
    cat <<EOF >> docker-compose.dev.yml
        depends_on:
EOF
fi

if [ "$3" == "y" ]; then
    cat <<EOF >> docker-compose.dev.yml
            postgres:
                condition: service_healthy
EOF
fi

if [ "$4" == "y" ]; then
    cat <<EOF >> docker-compose.dev.yml
            redis:
                condition: service_healthy
EOF
fi

cat <<EOF >> docker-compose.dev.yml
        ports:
          - "\${PORT}:\${PORT}"
        volumes:
          - .:/app/
        command: npm run dev
        networks:
          - app-network
EOF

if [ "$3" == "y" ]; then
    cat <<EOF >> docker-compose.dev.yml
    postgres:
        build:
            context: ./postgres
            dockerfile: Dockerfile
        env_file:
            - ./.env.dev
        volumes:
            - ./postgres/scripts/:/docker-entrypoint-initdb.d/
            - ./postgres/data:/var/lib/postgresql/data
        healthcheck:
            test: ["CMD-SHELL", "pg_isready"]
            interval: 10s
            timeout: 5s
            retries: 5      
        networks:
            - app-network
EOF
fi

if [ "$4" == "y" ]; then
    cat << EOF >> docker-compose.dev.yml
    redis:
        image: redis/redis-stack-server:7.2.0-v5
        env_file:
            - ./.env.dev
        volumes:
            - ./redis/data:/data
        healthcheck:
            test: ["CMD", "redis-cli", "-p", "\${REDIS_PORT}", "ping"]
            interval: 10s
            timeout: 5s
            retries: 5
        networks:
            - app-network
EOF
fi

cat <<EOF >> docker-compose.dev.yml
networks:
    app-network:
        driver: bridge
EOF


echo "Project structure created successfully!"

rm -rf ../setup.sh
