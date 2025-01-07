package logger

import (
	"log"
	"net/http"
	"time"
)

func Logger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Println("________________")
		log.Printf("Started %s %s \n", r.Method, r.URL.Path)

		start := time.Now()

		ww := &customWriter{ResponseWriter: w}

		next.ServeHTTP(ww, r)

		log.Printf("Completed %s %s in %v with status %d \n", r.Method, r.URL.Path, time.Since(start), ww.statusCode)
	})
}

type customWriter struct {
	http.ResponseWriter
	statusCode int
}

// overwrite WriteHeader

func (cW *customWriter) WriteHeader(statusCode int) {
	cW.statusCode = statusCode
	cW.ResponseWriter.WriteHeader(statusCode)
}
