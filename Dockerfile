# 以下内容生成docker镜像

# 构建阶段 可指定阶段别名 FROM amd64/golang:latest as build_stage
# 基础镜像
FROM golang:1.16.4-alpine3.13 AS builder

# 容器环境变量添加，会覆盖默认的变量值
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE="on"

# 作者
LABEL author="quinn"
LABEL email="qjpoo@163.com"

# 工作区
WORKDIR /app

# user
RUN adduser -u 10001 -D app

# 复制仓库源文件到容器里
COPY . .

# 编译可执行二进制文件(一定要写这些编译参数，指定了可执行程序的运行平台)
RUN go mod init gin && \
    go mod edit -require github.com/gin-gonic/gin@latest &&\
    go mod vendor && \
    ls -al  && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o webserver


# 构建生产镜像，使用最小的linux镜像，只有5M
# 同一个文件里允许多个FROM出现的，每个FROM被称为一个阶段，多个FROM就是多个阶段，最终以最后一个FROM有效，以前的FROM被抛弃
# 多个阶段的使用场景就是将编译环境和生产环境分开
# 参考：https://docs.docker.com/engine/reference/builder/#from
FROM alpine:latest AS final

WORKDIR /app

# 从编译阶段复制文件
# 这里使用了阶段索引值，第一个阶段从0开始，如果使用阶段别名则需要写成 COPY --from=build_stage /go/src/app/webserver /
COPY --from=builder /app/webserver .
COPY --from=builder /app/go.sum .
COPY --from=builder /app/go.mod .
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# 容器向外提供服务的暴露端口
EXPOSE 8080

USER app
# 启动服务
ENTRYPOINT ["/app/webserver"]
