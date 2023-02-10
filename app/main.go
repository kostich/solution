package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

var requestCount uint64

func main() {
	http.HandleFunc("/", writeHTTPResponse)
	http.HandleFunc("/healthz", healthCheck)

	httpPort, ok := os.LookupEnv("HTTP_PORT")
	if !ok {
		fmt.Printf("HTTP_PORT environment variable unspecified. Exiting.\n")
		os.Exit(1)
	}

	err := http.ListenAndServe(fmt.Sprintf(":%v", httpPort), nil)
	if err != nil {
		fmt.Printf("Can't start the HTTP server: %v\n", err)
		os.Exit(1)
	}
}

func writeHTTPResponse(w http.ResponseWriter, r *http.Request) {
	requestCount++
	hostname, _ := os.Hostname()
	io.WriteString(w, fmt.Sprintf("Hello from %v! I've been visited %v times so far.\n", hostname, requestCount))
	fmt.Printf("HTTP %v, client: %v, headers: %+v.\n", r.Method, r.RemoteAddr, r.Header)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "ok\n")
}
