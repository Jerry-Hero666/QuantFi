package main

import (
    "log"

    "github.com/gin-gonic/gin"

    "quantfi_backend/cmd/api-gateway/router"
)

func main() {
    r := gin.New()
    r.Use(gin.Logger(), gin.Recovery())

    router.Register(r)

    if err := r.Run(); err != nil {
        log.Fatalf("failed to start gin gateway: %v", err)
    }
}


