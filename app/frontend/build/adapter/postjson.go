package adapter

import (
	"app/model"
	"bytes"
	"encoding/json"
	"math/rand"
	"net/http"
	"net/http/httputil"

	log "github.com/sirupsen/logrus"
)

func RandomString(n int) string {
	var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

	s := make([]rune, n)
	for i := range s {
		s[i] = letters[rand.Intn(len(letters))]
	}
	return string(s)
}

func RandomNumbers(n int) string {
	var numbers = []rune("Z0123456789")

	s := make([]rune, n)
	for i := range s {
		s[i] = numbers[rand.Intn(len(numbers))]
	}
	return string(s)
}

func RandomSQLJSON() []byte {
	data := map[string]interface{}{
		"Type":        "cloudsql",
		"Name":        RandomString(rand.Intn(30)),
		"Surname":     RandomString(rand.Intn(50)),
		"Number":      RandomNumbers(rand.Intn(50)),
		"Description": RandomString(100),
		"Address":     RandomString(50),
	}
	payload, _ := json.MarshalIndent(data, "", "    ")
	return payload
}

func RandomPUBSUBJSON() []byte {
	data := map[string]interface{}{
		"Type":    "pubsub",
		"Message": RandomString(100),
	}
	payload, _ := json.MarshalIndent(data, "", "    ")
	return payload
}

func PostSQLJSON() []byte {
	var schema = model.BACKEND_SCHEMA
	var fqdn = model.BACKEND_FQDN
	var token = model.BACKEND_TOKEN
	payload := RandomSQLJSON()
	uri := schema + "://" + fqdn + "/v1/write"
	request, error := http.NewRequest("POST", uri, bytes.NewBuffer(payload))
	if error != nil {
		log.Warn(error)
	}
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")
	request.Header.Add("Authorization", "Bearer "+token)
	client := &http.Client{}
	response, error := client.Do(request)
	if error != nil {
		log.Warn(error)
	}
	defer response.Body.Close()
	log.Info("schema:" + schema + ",fqdn:" + fqdn + ",token:" + token)
	log.Info("response_status:", response.Status)

	clientResponse, _ := httputil.DumpResponse(response, true)
	return clientResponse
}

func PostPUBSUBJSON() []byte {
	var schema = model.BACKEND_SCHEMA
	var fqdn = model.BACKEND_FQDN
	var token = model.BACKEND_TOKEN
	payload := RandomPUBSUBJSON()
	uri := schema + "://" + fqdn + "/v1/write"
	request, error := http.NewRequest("POST", uri, bytes.NewBuffer(payload))
	if error != nil {
		log.Warn(error)
	}
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")
	request.Header.Add("Authorization", "Bearer "+token)
	client := &http.Client{}
	response, error := client.Do(request)
	if error != nil {
		log.Warn(error)
	}
	defer response.Body.Close()
	log.Info("schema:" + schema + ",fqdn:" + fqdn + ",token:" + token)
	log.Info("response_status:", response.Status)

	clientResponse, _ := httputil.DumpResponse(response, true)
	return clientResponse
}
