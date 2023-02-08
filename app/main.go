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
	io.WriteString(w, fmt.Sprintf("Hello there! I've been visited %v times so far.\n", requestCount))
}
