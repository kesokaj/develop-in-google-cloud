package adapter

import (
	"github.com/gorilla/mux"
)

var Route = mux.NewRouter().StrictSlash(true)
