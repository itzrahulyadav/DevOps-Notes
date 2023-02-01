package main

import (
	"fmt"
	"log"
	"net/http"
)

func main(){
	fileServer := http.FileServer(http.Dir("./static"))
}