##
## Build
##
FROM golang:alpine AS build
LABEL maintainer="Simon Östling <spgo@google.com>"
WORKDIR /build
COPY . .
RUN go build -o main
##
## Deploy
##
FROM alpine
WORKDIR /app
COPY --from=build /build/main main
COPY --from=build /build/values.json values.json
EXPOSE 8080
CMD ["./main"]