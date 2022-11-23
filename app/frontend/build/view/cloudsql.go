package view

import (
	"app/adapter"
	"net/http"
)

func CloudSQL(w http.ResponseWriter, r *http.Request) {
	adapter.Tmpl.ExecuteTemplate(w, "header", adapter.Head{PageTitle: "CloudSQL"})
	adapter.Tmpl.ExecuteTemplate(w, "menu", nil)
	adapter.Tmpl.ExecuteTemplate(w, "cloudsql", nil)
	adapter.Tmpl.ExecuteTemplate(w, "footer", nil)
}

func CloudSQLAddROW(w http.ResponseWriter, r *http.Request) {
	r.Header.Set("Content-Type", "application/json; charset=UTF-8")
	result := adapter.PostSQLJSON()
	w.Write(result)
}
