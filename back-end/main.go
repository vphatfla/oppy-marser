package main

import (
	"log"
	"net/http"

	"github.com/a-h/templ"
	"vphatfla.com/vphatfla/handlers"
	"vphatfla.com/vphatfla/html"
	"vphatfla.com/vphatfla/logger"
)

func main() {
	log.Println("Backend Server Started, listening on port 8000!")

	mux := http.NewServeMux()

	http.Handle("/404", http.NotFoundHandler())

	// middleware logger request, logger intercept the incoming req to the mux
	http.Handle("/", logger.Logger(mux))

	mux.HandleFunc("/blog", handlers.Blog)
	mux.HandleFunc("/contact", handlers.Contact)

	// test route for templ
	h := html.Hello("Oppy")
	mux.Handle("/hello", templ.Handler(h))
	ho := html.Home()
	mux.Handle("/home", templ.Handler(ho))
	log.Fatal(http.ListenAndServe(":8000", nil))
}
