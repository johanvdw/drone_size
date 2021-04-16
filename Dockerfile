FROM alpine
RUN apk add git bash
COPY git-size.sh /bin
ENTRYPOINT /bin/git-size.sh
