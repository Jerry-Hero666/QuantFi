package main

import (
    "flag"
    "fmt"
    "log"

    "github.com/zeromicro/go-zero/core/conf"
    "github.com/zeromicro/go-zero/rest"

    "quantfi_backend/internal/handler"
    "quantfi_backend/internal/svc"
)

var configFile = flag.String("f", "etc/trading.yaml", "the config file")

func main() {
    flag.Parse()

    var c rest.Config
    if err := conf.ReadConfig(*configFile, &c); err != nil {
        log.Fatalf("failed to read config: %v", err)
    }

    ctx := svc.NewServiceContext(c)
    server := rest.MustNewServer(c)
    defer server.Stop()

    handler.RegisterHandlers(server, ctx)

    fmt.Printf("Starting trading service at %s:%d...\n", c.Host, c.Port)
    server.Start()
}


