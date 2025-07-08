package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/a-h/templ"
	"github.com/go-chi/chi/v5"
	"vphatfla.com/vphatfla/blogs"
	"vphatfla.com/vphatfla/components"
	"vphatfla.com/vphatfla/internal/middleware"
	"vphatfla.com/vphatfla/models"
)

func main() {
	r := chi.NewRouter()

	// Middlware
	r.Use(middleware.Logger)

	articles, err := blogs.RenderAndReturnArticles("blogs/md", "blogs/html")
	if err != nil {
		fmt.Printf("Error rendering html %s", err.Error())
		panic(1)
	}

	h := components.Hello("Oppy")
	r.Handle("/hello", templ.Handler(h))

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
	bl := components.Blog(articles)
	co := components.Contact()

	r.Route("/api", func(r chi.Router) {
		r.Handle("/home", templ.Handler(ho))
		r.Handle("/blog", templ.Handler(bl))
		r.Handle("/contact", templ.Handler(co))
		// articles route
		for _, a := range articles {
			aTempl := components.Article(a)
			r.Handle("/api/article/"+a.Name, templ.Handler(aTempl))
		}
	})

	log.Println("Backend Server Started, listening on port 8000!")
	log.Fatal(http.ListenAndServe(":8000", r))
}
