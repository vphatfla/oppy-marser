package main

import (
	"log"
	"net/http"

	"github.com/a-h/templ"
	"vphatfla.com/vphatfla/components"
	"vphatfla.com/vphatfla/logger"
	"vphatfla.com/vphatfla/models"
)

func main() {
	log.Println("Backend Server Started, listening on port 8000!")

	mux := http.NewServeMux()

	http.Handle("/404", http.NotFoundHandler())

	// middleware logger request, logger intercept the incoming req to the mux
	http.Handle("/", logger.Logger(mux))

	// mux.HandleFunc("/blog", handlers.Blog)
	// mux.HandleFunc("/contact", handlers.Contact)
	// test route for templ
	h := components.Hello("Oppy")
	mux.Handle("/hello", templ.Handler(h))

	exps := []models.Experience{
		{
			Company:     "University of Central Florida",
			Description: "Architecture and application of AI in Inverted Based Resource devices",
		},
		{
			Company:     "Apple",
			Description: "Distributed Tracing - Observability Tooling for distributed system",
		},
		{
			Company:     "Leidos",
			Description: "Serverless Microsoft document automation application to reduce operational overhead",
		},
		{
			Company:     "JP Morgan Chase Co",
			Description: "Reporting Data - Batch Ingestion and Provisioning applications",
		},
	}
	ho := components.Home(exps)
	mux.Handle("/api/home", templ.Handler(ho))
	bl := components.Blog()
	mux.Handle("/api/blog", templ.Handler(bl))
	co := components.Contact()
	mux.Handle("/api/contact", templ.Handler(co))

	log.Fatal(http.ListenAndServe(":8000", nil))
}
