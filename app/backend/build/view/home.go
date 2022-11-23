package view

import (
	"app/adapter"
	"net/http"
)

func Home(w http.ResponseWriter, r *http.Request) {
	r.Header.Set("Content-Type", "application/json; charset=UTF-8")
	result := adapter.PrintHeaders(r)
	w.Write([]byte(result))
}
