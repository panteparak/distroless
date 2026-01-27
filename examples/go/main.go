// Package main provides a simple HTTP server example for Go with distroless.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
)

// Response represents the JSON response structure.
type Response struct {
	Message   string `json:"message"`
	GoVersion string `json:"goVersion"`
	Path      string `json:"path"`
	Method    string `json:"method"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handler)

	log.Printf("Server running on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := Response{
		Message:   "Hello from distroless Go!",
		GoVersion: runtime.Version(),
		Path:      r.URL.Path,
		Method:    r.Method,
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}

	fmt.Printf("[HTTP] %s %s\n", r.Method, r.URL.Path)
}
