FROM alpine
RUN apk add --update make crystal shards libc-dev
WORKDIR /app
CMD make static=yes
