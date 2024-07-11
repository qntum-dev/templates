ARG BUILD_IMAGE=node:20.1.0
ARG RUN_IMAGE=gcr.io/distroless/nodejs20-debian11
ARG BUILD_DIR=default
ARG PROD_DIR=default

FROM ${BUILD_IMAGE} AS build

WORKDIR /${BUILD_DIR}

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

FROM ${RUN_IMAGE}

WORKDIR /${PROD_DIR}

COPY --from=build /${BUILD_DIR} .

CMD ["node","index.js"] 
