FROM golang:1.16

WORKDIR /go/src/app
COPY main.go go.mod ./

ENV GO111MODULE=on
RUN go mod tidy
RUN go build .

EXPOSE 3000
CMD ./app
