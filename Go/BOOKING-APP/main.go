package main

import (
	"fmt"
	"strings"
)

func main() {

	conferenceName := "Go reference"
	const tickets = 50

	var remaining uint = 50
	var bookings []string

	fmt.Printf("tickets is %T", tickets)
	fmt.Printf("Welcome to our %v conference booking application\n", conferenceName)
	fmt.Println("we have total of ", remaining)
	fmt.Println("Get your tickets here to attend")

	for remaining > 0 && len(bookings) < 50 {
		var firstname string
		var lastname string
		var email string
		var userTickets uint

		fmt.Println("enter your first name")
		fmt.Scanln(&firstname)
		fmt.Println("enter your last name")
		fmt.Scanln(&lastname)
		fmt.Println("enter your email name")
		fmt.Scanln(&email)
		fmt.Println("enter the number of tickets")
		fmt.Scanln(&userTickets)

		if userTickets <= remaining {
			remaining = remaining - userTickets
			bookings = append(bookings, firstname+" "+lastname)
			fmt.Printf("the total bookings are %v\n", bookings)

			firstNames := []string{}
			for _, booking := range bookings {
				var names = strings.Fields(booking)
				firstNames = append(firstNames, names[0])
			}
			if remaining == 0 {
				fmt.Println("The show is house full,come back tomorrow")
				break
			}
			fmt.Printf("the first name of the bookings are %v\n", firstNames)
		} else {
			fmt.Printf("we only have %v tickets remaining ,so you cannot book %v tickets\n", remaining, userTickets)
			continue
		}
	

	}

}
