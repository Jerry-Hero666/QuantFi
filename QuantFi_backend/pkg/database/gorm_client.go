package database

import (
	"log"
	"sync"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var (
	once sync.Once
	db   *gorm.DB
)

func MustInit(dsn string, opts ...gorm.Option) *gorm.DB {
	once.Do(func() {
		conn, err := gorm.Open(postgres.Open(dsn), opts...)
		if err != nil {
			log.Fatalf("failed to connect database: %v", err)
		}
		db = conn
	})
	return db
}

func DB() *gorm.DB {
	if db == nil {
		log.Fatal("gorm client not initialized")
	}
	return db
}
