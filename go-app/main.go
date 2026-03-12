// Package main — HTTP server para demonstracao Docker.
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

var startTime = time.Now()

type response struct {
	Service  string `json:"service"`
	Status   string `json:"status"`
	Hostname string `json:"hostname,omitempty"`
}

type healthResponse struct {
	Status        string  `json:"status"`
	UptimeSeconds float64 `json:"uptime_seconds"`
	Version       string  `json:"version"`
	GoVersion     string  `json:"go_version"`
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	resp := response{
		Service:  "go-app",
		Status:   "running",
		Hostname: hostname,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	uptime := time.Since(startTime).Seconds()
	version := os.Getenv("APP_VERSION")
	if version == "" {
		version = "1.0.0"
	}
	resp := healthResponse{
		Status:        "healthy",
		UptimeSeconds: uptime,
		Version:       version,
		GoVersion:     "1.23",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func main() {
	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/health", healthHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server running on port %s\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
