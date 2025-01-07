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

	mux.HandleFunc("/home", handlers.Home)
	mux.HandleFunc("/blog", handlers.Blog)
	mux.HandleFunc("/contact", handlers.Contact)

	http.Handle("/404", http.NotFoundHandler())

	http.Handle("/", logger.Logger(mux))

	log.Fatal(http.ListenAndServe(":8000", nil))
}
