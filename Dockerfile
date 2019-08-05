FROM golang:1.12-alpine as builder

ENV GO111MODULE on
ENV APPDIR /go/src/github.com/ilovelili/micro

RUN apk update && apk add --no-cache --update git ca-certificates
WORKDIR $APPDIR
ADD . .
RUN go mod download
RUN go mod verify

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o micro .

FROM scratch

ENV APPDIR /go/src/github.com/ilovelili/micro
ENV CORS_ALLOWED_HEADERS "Content-Type,Accept,Authorization"
ENV CORS_ALLOWED_ORIGINS "*"
ENV CORS_ALLOWED_METHODS "GET,POST"

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder $APPDIR/micro ./micro
ENTRYPOINT ["./micro"]
CMD ["api","--namespace=dongfeng.svc.core.proxy","--handler=http","--address=0.0.0.0:8080"]