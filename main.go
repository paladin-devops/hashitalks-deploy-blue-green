package main

import (
	"net/http"

	_ "github.com/lib/pq"
)

func main() {
	connectHandler := ConnectHandler{}
	err := http.ListenAndServe(":80", connectHandler)
	if err != nil {
		return
	}
}

type ConnectHandler struct{}

func (c ConnectHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello World!"))
}
