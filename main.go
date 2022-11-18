package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"
	"strconv"

	_ "github.com/lib/pq"
)

func main() {
	http.HandleFunc("/connect", connect)
	err := http.ListenAndServe(":80", nil)
	if err != nil {
		return
	}
}

func connect(w http.ResponseWriter, r *http.Request) {
	type conn struct {
		user     string
		password string
		port     int
		host     string
		dbname   string
	}

	port, err := strconv.Atoi(os.Getenv("PORT"))
	if err != nil {
		panic(err)
	}
	connection := conn{
		user:     os.Getenv("USERNAME"),
		password: os.Getenv("PASSWORD"),
		port:     port,
		host:     os.Getenv("HOST"),
		dbname:   os.Getenv("DBNAME"),
	}

	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
		"password=%s dbname=%s sslmode=disable",
		connection.host, connection.port, connection.user, connection.password, connection.dbname)
	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		fmt.Println("Failed to connect. :(")
	}

	fmt.Printf("Connected to the database!")
	fmt.Println("Successfully connected! :)")
}
