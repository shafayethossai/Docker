# FROM node:18

# ENV MONGO_DB_USERNAME=admin \
#     MONGO_DB_PWD=qwerty

# RUN mkdir -p testapp

# COPY . /testapp

# CMD ["node", "/testapp/server.js"]


FROM node:18

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=qwerty

WORKDIR /testapp

COPY . .

EXPOSE 5050

CMD ["node", "server.js"]