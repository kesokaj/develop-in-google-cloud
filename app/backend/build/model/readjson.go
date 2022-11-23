package model

import (
	"encoding/json"
	"os"
)

func ReadJson(jsonFile string) map[string]string {
	plan, _ := os.ReadFile(jsonFile)
	var data map[string]string
	json.Unmarshal(plan, &data)
	return data
}
