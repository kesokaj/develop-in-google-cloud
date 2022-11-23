package main

import (
	"app/adapter"
	"app/model"
	"app/view"
	"net/http"
	"os"
	"runtime"
	"time"

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
	adapter.Route.HandleFunc("/pubsub", view.PubSub)
	adapter.Route.HandleFunc("/pubsub/publish", view.PubSubPublish)
	adapter.Route.HandleFunc("/cloudsql", view.CloudSQL)
	adapter.Route.HandleFunc("/cloudsql/addrow", view.CloudSQLAddROW)
	adapter.Route.PathPrefix("/").Handler(http.FileServer(http.Dir("./assets/")))

	cfg := &http.Server{
		Addr:         ":8080",
		Handler:      adapter.Route,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}
	log.Warn(cfg.ListenAndServe())
}
