package view

import (
	"app/adapter"
	"net/http"
)

func Home(w http.ResponseWriter, r *http.Request) {
	adapter.Tmpl.ExecuteTemplate(w, "header", adapter.Head{PageTitle: "Home"})
	adapter.Tmpl.ExecuteTemplate(w, "menu", nil)
	adapter.Tmpl.ExecuteTemplate(w, "headers", adapter.PrintHeaders(r))
	adapter.Tmpl.ExecuteTemplate(w, "footer", nil)
}
