package model

import (
	"context"

	"contrib.go.opencensus.io/exporter/stackdriver"
	log "github.com/sirupsen/logrus"
	"go.opencensus.io/trace"
)

func InitTrace() {
	sdx, err := stackdriver.NewExporter(stackdriver.Options{
		ProjectID:    GetEnv("GOOGLE_CLOUD_PROJECT", PROJECT_ID),
		MetricPrefix: GetEnv("APP_NAME", "frontend"),
		Context:      context.Background(),
	})
	if err != nil {
		log.Warn(err)
	}
	defer sdx.Flush()
	trace.RegisterExporter(sdx)
	trace.ApplyConfig(trace.Config{DefaultSampler: trace.ProbabilitySampler(1 / 10.0)})
	/*trace.ApplyConfig(trace.Config{DefaultSampler: trace.AlwaysSample()})*/
}
