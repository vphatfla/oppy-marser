FROM golang:1.23-alpine

WORKDIR /usr/src/bin/app

COPY go.mod go.sum ./

RUN go mod download

COPY . . 

RUN go build -v -o ./go-app

EXPOSE 8000

CMD ["./go-app"] 
