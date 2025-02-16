package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"github.com/gorilla/mux"
)


type Product struct {
	ID string	`json:"id"`
	Name string	`json:"name"`				
	Price float64	`json:"price"`
	Quantity int	`json:"quantity"`
}	

var Products []Product 

func homepage(w http.ResponseWriter, r *http.Request){
		fmt.Fprintf(w, "Welcome to the HomePage!")
		log.Println("endpoint hit: homepage")
}

func returnAllProducts(w http.ResponseWriter, r *http.Request){
	log.Println("endpoint hit: AllProducts")
	json.NewEncoder(w).Encode(Products)
}

func getProduct(w http.ResponseWriter, r *http.Request){
     vars := mux.Vars(r)
	 key := vars["id"]

	 for _,product := range Products {	
		 if string(product.ID) == key {
			 json.NewEncoder(w).Encode(product)
		 }
	 }	

}
func HandleRequest() {
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.HandleFunc("/products", returnAllProducts)
	myRouter.HandleFunc("/products/{id}", getProduct)
	myRouter.HandleFunc("/", homepage)
	http.ListenAndServe(":8080", myRouter)
}

func main(){
	Products = []Product{
		Product{ID: "1", Name: "Laptop", Price: 1000.00, Quantity: 10},		
		Product{ID: "2", Name: "Mouse", Price: 10.00, Quantity: 50},
		Product{ID: "3", Name: "Keyboard", Price: 20.00, Quantity: 30},
	}
	HandleRequest()
}