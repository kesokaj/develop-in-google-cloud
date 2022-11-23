package adapter

import (
	"html/template"

	"github.com/gorilla/mux"
)

type Head struct {
	PageTitle string
}

var Route = mux.NewRouter().StrictSlash(true)
var Tmpl = template.Must(template.ParseGlob("view/template/*.gohtml"))
