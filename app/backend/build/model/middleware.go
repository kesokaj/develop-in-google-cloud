package model

import (
	"net/http"

	"cloud.google.com/go/logging"
	log "github.com/sirupsen/logrus"
	"go.opencensus.io/trace"
)

func GCPAddTrace(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		isHTTPS := r.TLS != nil
		var fullURI string
		if isHTTPS {
			fullURI = "https://" + r.Host + r.RequestURI
		} else {
			fullURI = "http://" + r.Host + r.RequestURI
		}
		_, span := trace.StartSpan(r.Context(), r.RequestURI)
		span.SetStatus(trace.Status{
			Code: trace.StatusCodeOK,
		})
		span.AddAttributes(
			trace.StringAttribute("/http/host", r.Host),
			trace.StringAttribute("/http/method", r.Method),
			trace.Int64Attribute("/http/status_code", http.StatusOK),
			trace.StringAttribute("/http/client_protocol", r.Proto),
			trace.StringAttribute("/http/user_agent", r.UserAgent()),
			trace.StringAttribute("/http/url", fullURI),
			trace.StringAttribute("/http/route", r.RequestURI),
		)
		defer span.End()

		traceIsSampled := span.SpanContext().IsSampled()
		if traceIsSampled {
			traceID := span.SpanContext().TraceID.String()
			traceURI := "projects/" + GetEnv("GOOGLE_CLOUD_PROJECT", PROJECT_ID) + "/traces/" + traceID
			spanID := span.SpanContext().SpanID.String()
			cli, err := logging.NewClient(r.Context(), GetEnv("GOOGLE_CLOUD_PROJECT", PROJECT_ID))
			if err != nil {
				log.Warn(err)
			}
			defer cli.Close()
			gLog := cli.Logger("traces")
			gEntry := logging.Entry{
				HTTPRequest: &logging.HTTPRequest{
					Request:                        r,
					Status:                         http.StatusOK,
					RequestSize:                    r.ContentLength,
					LocalIP:                        r.Host,
					RemoteIP:                       r.RemoteAddr,
					CacheHit:                       true,
					CacheValidatedWithOriginServer: true,
					CacheLookup:                    true,
				},
				Payload:      "GCPTraceLog",
				Trace:        traceURI,
				SpanID:       spanID,
				TraceSampled: true,
			}
			gLog.Log(gEntry)
			defer gLog.Flush()
			w.Header().Set("X-Cloud-Trace-Context", traceID+"/"+spanID+";o=TRUE")
		}

		next.ServeHTTP(w, r)
	})
}
