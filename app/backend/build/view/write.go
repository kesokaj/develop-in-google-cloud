package view

import (
	"app/model"
	"encoding/json"
	"net/http"
	"strings"
)

func Write(w http.ResponseWriter, r *http.Request) {
	var ReadToken = strings.Split(r.Header.Get("Authorization"), "Bearer")
	var Token = strings.TrimSpace(ReadToken[1])
	var JSONData map[string]interface{}
	json.NewDecoder(r.Body).Decode(&JSONData)
	w.Header().Set("Content-Type", "application/json")
	if Token == model.BACKEND_TOKEN {
		if JSONData["Type"] == "pubsub" {
			result := model.PUBTheSUB(JSONData)
			w.Write(result)
		} else if JSONData["Type"] == "cloudsql" {
			result := model.AddROW(JSONData, "sample-db")
			w.Write(result)
		} else {
			JSONData["Error"] = "Missing field or type in query"
			JSONtoByte, _ := json.MarshalIndent(JSONData, "", "    ")
			w.Write(JSONtoByte)
		}
	}
}
