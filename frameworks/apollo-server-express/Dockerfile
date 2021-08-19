FROM node:16.6.2-slim
ENV NODE_ENV production
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
EXPOSE 3000

RUN mkdir /app && chown -R node:node /app
WORKDIR /app
USER node
COPY --chown=node:node package.json ./
RUN npm install --no-audit && npm cache clean --force

COPY --chown=node:node app.js ./

ENTRYPOINT ["/tini", "--"]
CMD ["node", "./app.js"]
