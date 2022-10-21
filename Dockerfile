FROM node:19

WORKDIR /app
COPY package*.json /app/
RUN npm install

COPY . /app/
RUN npm run build

ENV HOST 0.0.0.0
ENV PROT 3000
CMD npm run start
