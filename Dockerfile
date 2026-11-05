FROM node:20-alpine
ARG RELEASE_VERSION=v2.3.0
LABEL org.opencontainers.image.title="OrderFlow" \
      org.opencontainers.image.version="${RELEASE_VERSION}"
ENV NODE_ENV=production
WORKDIR /app
COPY app/package*.json ./
RUN npm install --omit=dev
COPY app/ .
USER node
EXPOSE 3000
CMD ["npm", "start"]
