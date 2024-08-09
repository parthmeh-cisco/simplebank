# Build stage
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o main main.go

# Run stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
COPY app.env .

# Ensure the binary has execute permissions
RUN chmod +x /app/main

EXPOSE 8080
CMD [ "/app/main" ]