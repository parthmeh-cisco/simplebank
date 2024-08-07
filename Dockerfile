FROM golang:1.16.3-alpine3.13

WORKDIR /app

# Set environment variables to avoid using the Go module proxy
ENV GOPROXY=direct
ENV GOSUMDB=off

# Copy go.mod and go.sum files first to leverage Docker layer caching
COPY go.mod .
COPY go.sum .

# Download all dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the application
RUN go build -o main main.go

EXPOSE 8080

CMD ["/app/main"]