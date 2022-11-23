package model

import (
	"encoding/json"
	"fmt"
	"strconv"

	log "github.com/sirupsen/logrus"
)

func AddROW(data map[string]interface{}, tbl string) []byte {
	delete(data, "Type")
	var key string
	var val string
	for k, v := range data {
		key += k + ", "
		val += "'" + fmt.Sprintf("%v", v) + "', "
	}
	if len(key) > 3 {
		makeQuery := "INSERT INTO `" + tbl + "` (" + key[:len(key)-2] + ") VALUES (" + val[:len(val)-2] + ")"
		sqlQuery := makeQuery
		db := DbConnect()
		res, err := db.Exec(sqlQuery)
		if err != nil {
			log.Error(err)
			data = map[string]interface{}{
				"error": err,
			}
		} else {
			lastInsertID, _ := res.LastInsertId()
			affected, _ := res.RowsAffected()
			LID := strconv.Itoa(int(lastInsertID))
			AFF := strconv.Itoa(int(affected))
			data = map[string]interface{}{
				"InsertID":     lastInsertID,
				"RowsAffected": affected,
				/*"query":        sqlQuery, only for debugging */
			}
			log.Info("InsertID: " + LID + ";RowsAffected: " + AFF)
		}
		defer db.Close()
	} else {
		data = map[string]interface{}{
			"response": "empty query",
		}
		log.Warn("empty query")
	}
	payload, _ := json.MarshalIndent(data, "", "    ")
	return payload
}
