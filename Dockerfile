# Build stage
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o main main.go

# Run stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./db/migration

# Ensure the binary has execute permissions
RUN chmod +x /app/main /app/start.sh /app/wait-for.sh

EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]
