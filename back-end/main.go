package main

import (
	"log"
	"net/http"

	"vphatfla.com/vphatfla/handlers"
	"vphatfla.com/vphatfla/logger"
)

func main() {
	log.Println("Backend Server Started!")

	mux := http.NewServeMux()

	http.Handle("/404", http.NotFoundHandler())

	// middleware logger request, logger intercept the incoming req to the mux
	http.Handle("/", logger.Logger(mux))

	mux.HandleFunc("/home", handlers.Home)
	mux.HandleFunc("/blog", handlers.Blog)
	mux.HandleFunc("/contact", handlers.Contact)

	log.Fatal(http.ListenAndServe(":8000", nil))
}
