FROM alpine
RUN apk add --update crystal shards libc-dev
WORKDIR /app
CMD shards build --release --static
