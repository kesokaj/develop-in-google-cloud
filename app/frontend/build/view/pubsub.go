package view

import (
	"app/adapter"
	"net/http"
)

func PubSub(w http.ResponseWriter, r *http.Request) {
	adapter.Tmpl.ExecuteTemplate(w, "header", adapter.Head{PageTitle: "PUB/SUB"})
	adapter.Tmpl.ExecuteTemplate(w, "menu", nil)
	adapter.Tmpl.ExecuteTemplate(w, "pubsub", nil)
	adapter.Tmpl.ExecuteTemplate(w, "footer", nil)
}

func PubSubPublish(w http.ResponseWriter, r *http.Request) {
	r.Header.Set("Content-Type", "application/json; charset=UTF-8")
	result := adapter.PostPUBSUBJSON()
	w.Write(result)
}
