package handlers

import (
	"fmt"
	"net/http"
)

func Contact(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Contact Request")
}
