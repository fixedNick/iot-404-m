FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o main main.go

# Этап 2: Финальный образ
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/config ./config
EXPOSE 50051
CMD ["./main"]