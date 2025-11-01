package router

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

func Register(r *gin.Engine) {
    api := r.Group("/api")
    {
        api.GET("/health", func(c *gin.Context) {
            c.JSON(http.StatusOK, gin.H{"status": "ok"})
        })
    }
}


