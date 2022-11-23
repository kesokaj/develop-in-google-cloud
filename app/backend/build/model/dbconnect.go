package model

import (
	"database/sql"
	"time"

	log "github.com/sirupsen/logrus"
)

func DbConnect() *sql.DB {
	db, err := sql.Open("mysql", SQL_USER+":"+SQL_USER_PASSWORD+"@tcp("+SQL_ENDPOINT+":3306)/"+SQL_DATABASE+"?timeout=15s")
	/*db, err := sql.Open("mysql", SQL_USER+":"+SQL_USER_PASSWORD+"@tcp(35.228.235.217:3306)/"+SQL_DATABASE+"?timeout=15s")*/

	if err != nil {
		log.WithFields(log.Fields{
			"Output": err.Error(),
		}).Info("db is not connected")
	}
	err = db.Ping()
	if err != nil {
		log.WithFields(log.Fields{
			"Output": err.Error(),
		}).Error("db is not connected")
	}
	db.SetMaxOpenConns(50)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(time.Second * 10)

	return db
}
