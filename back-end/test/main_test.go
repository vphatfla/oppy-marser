package test

import (
	"net/http/httptest"
	"testing"

	"vphatfla.com/vphatfla/handlers"
)

func TestRoutes(t *testing.T) {
	routes := []struct{
		name string
		method string
		expectedCode int
		route string
	} {
		{
			name: "HOME",
			method: "GET",
			route: "/api/home",
			expectedCode: 200,
		},
		{
			name: "BLOG",
			method: "GET",
			route: "/api/blog",
			expectedCode: 200,
		},
		{
			name: "CONTACT",
			method: "GET",
			route: "/api/contact",
			expectedCode: 200,
		},
	}

	for _,r := range routes {
		req := httptest.NewRequest(r.method, r.route, nil)
		w := httptest.NewRecorder()
		if r.name == "HOME" {
			handlers.Home(w, req)
		} else if r.name == "BLOG" {
			handlers.Blog(w, req)
		} else {
			handlers.Contact(w, req) 
		}
		
		if w.Code != r.expectedCode {
			t.Fatalf("Expect %v, got %v", r.expectedCode, w.Code)
		}

	}
}
