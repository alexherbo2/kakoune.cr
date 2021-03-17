FROM alpine
RUN apk add --update make crystal shards libc-dev yaml-static
WORKDIR /app
CMD sh
