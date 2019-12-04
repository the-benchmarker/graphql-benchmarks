FROM node:12.13.1-alpine
ENV NODE_ENV production
EXPOSE 3000

WORKDIR /usr/src/app
COPY package.json ./
RUN npm install

COPY app.js ./

CMD node app.js