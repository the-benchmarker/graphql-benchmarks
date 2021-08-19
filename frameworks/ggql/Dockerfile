FROM golang:1.16

WORKDIR /go/src/song
COPY main.go go.mod song.graphql ./

ENV GO111MODULE=on
RUN go mod tidy
RUN go build .

EXPOSE 3000
CMD ./song
