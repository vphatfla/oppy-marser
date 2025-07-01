package middleware

import (
	"log"
	"net/http"
	"time"
)

type responseWriter struct {
	http.ResponseWriter
	code int
}

func (w *responseWriter) WriteHeader(code int) {
	w.code = code
	w.ResponseWriter.WriteHeader(code)
}

func Logger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		wrapped := &responseWriter{
			ResponseWriter: w,
			code: 0,
		}
		next.ServeHTTP(wrapped, r)
		log.Printf("StatusCode %v  |   Request URL %v   |   At %v", wrapped.code, r.URL.Path, time.Now())
	})
}
