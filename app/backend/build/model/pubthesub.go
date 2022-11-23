package model

import (
	"context"
	"encoding/json"
	"strings"

	"cloud.google.com/go/pubsub"
	log "github.com/sirupsen/logrus"
)

func PUBTheSUB(data map[string]interface{}) []byte {
	byteMSG, _ := json.Marshal(data["Message"])
	msg := strings.Trim(string(byteMSG), "\"")
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, PROJECT_ID)
	if err != nil {
		log.Warn("pubsub.NewClient: ", err)
	}
	defer client.Close()

	t := client.Topic(PUBSUB_TOPIC)
	t.PublishSettings.NumGoroutines = 1
	result := t.Publish(ctx, &pubsub.Message{Data: []byte(msg)})
	id, err := result.Get(ctx)
	if err != nil {
		log.Warn("Get: %v", err)
	}
	log.Info("Published a message: Message:"+msg+" ID:", id)

	data = map[string]interface{}{
		"ID":      id,
		"Message": msg,
	}
	payload, _ := json.MarshalIndent(data, "", "    ")
	return payload
}
