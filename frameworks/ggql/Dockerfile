FROM golang:1.14.0

WORKDIR /go/src/song
COPY main.go go.mod song.graphql ./

ENV GO111MODULE=on
RUN go build .

EXPOSE 3000
CMD ./song
