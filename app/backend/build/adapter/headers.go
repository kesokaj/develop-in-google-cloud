package adapter

import (
	"net/http"
	"net/http/httputil"

	log "github.com/sirupsen/logrus"
)

func PrintHeaders(req *http.Request) string {
	requestDump, err := httputil.DumpRequest(req, true)
	if err != nil {
		log.Warn(err)
	}
	return string(requestDump)
}
