package main

import (
	"fmt"
	"log"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/hello" {
		http.Error(w, "404 not found", http.StatusNotFound)
		return
	}

	// if r.Method != "Get" {
	// 	http.Error(w, "method is not supported", http.StatusNotFound)
	// 	return
	// }

	fmt.Fprintf(w, "hello!")

}

func formHandler(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm();err != nil {
		fmt.Fprintf(w,"ParseForm() err : % v",err)
		return
	}

	fmt.Fprintf(w,"Post request Successful")
	name := r.FormValue("name")
	city := r.FormValue("city")

	fmt.Fprintf(w,"Name = %s\n",name)
	fmt.Fprintf(w,"City = %s\n",city)
}
func main() {
	fileServer := http.FileServer(http.Dir("./static"))
	http.Handle("/", fileServer)
	http.HandleFunc("/form", formHandler)
	http.HandleFunc("/hello", helloHandler)

	fmt.Printf("server is running at port 8000\n")

	if err := http.ListenAndServe(":8000", nil); err != nil {
		log.Fatal(err)
	}
}
