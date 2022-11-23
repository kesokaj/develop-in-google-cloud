package main

import (
	"app/adapter"
	"app/model"
	"app/view"
	"net/http"
	"os"
	"runtime"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	log "github.com/sirupsen/logrus"
)

func init() {
	model.InitTrace()
	model.InitProfiler()
	runtime.GOMAXPROCS(2)
	log.SetFormatter(&log.JSONFormatter{})
	log.SetOutput(os.Stdout)
}

func main() {
	adapter.Route.Handle("/metrics", promhttp.Handler())
	adapter.Route.Use(model.GCPAddTrace)
	adapter.Route.HandleFunc("/", view.Home)
	adapter.Route.HandleFunc("/v1/write", view.Write)
	adapter.Route.HandleFunc("/v1/read", view.Read)

	cfg := &http.Server{
		Addr:         ":8080",
		Handler:      adapter.Route,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}
	log.Warn(cfg.ListenAndServe())
}
