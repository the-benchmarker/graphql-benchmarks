FROM golang:1.13.4

WORKDIR /go/src/app
COPY main.go go.mod ./

ENV GO111MODULE=on
RUN go build .

EXPOSE 3000
CMD ./app
