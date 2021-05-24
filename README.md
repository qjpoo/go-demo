# democice
```
go.mod Golang启用了模块管理功能
go.sum 启用模块管理时，会在此文件中记录依赖的三方库
main.go 我们的主要go程序文件，一个简单的webserver应用

docker build -t web .
docker run -d --rm --name web -p 8080:8080 web
docker exec -it web sh
```
