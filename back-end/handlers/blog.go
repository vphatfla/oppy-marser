package handlers

import (
	"fmt"
	"net/http"
)

func Blog(w http.ResponseWriter, r *http.Request) {
	fmt.Println("BLOG Request")
}
