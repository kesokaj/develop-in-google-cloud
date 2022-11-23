package model

import (
	"cloud.google.com/go/profiler"
	log "github.com/sirupsen/logrus"
)

func InitProfiler() {
	cfg := profiler.Config{
		Service:        GetEnv("APP_NAME", "frontend"),
		ServiceVersion: GetEnv("APP_VERSION", "v1"),
		ProjectID:      GetEnv("GOOGLE_CLOUD_PROJECT", PROJECT_ID),
		DebugLogging:   false,
	}
	if err := profiler.Start(cfg); err != nil {
		log.Warn(err)
	}
}
