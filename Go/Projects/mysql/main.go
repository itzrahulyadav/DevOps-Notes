package main

import (
	"database/sql"
	"fmt"
	"log"
	_ "github.com/go-sql-driver/mysql"
)


func checkError(e error) {
	if e != nil {
		log.Fatalln(e)
	}
}

type Data struct {
	id int
	name string
}
func main() {	
    connectionString := fmt.Sprintf("%v:%v@tcp(3.111.213.94:3306)/%v", Dbuser, Dbpassword, DBName)

	db, err := sql.Open("mysql", connectionString)
    checkError(err)
     fmt.Print(db)
	 defer db.Close()


	result,err := db.Exec("INSERT INTO data VALUES(5,'whocares')")
    checkError(err)
	fmt.Println(result.LastInsertId())
	
	rows, err := db.Query("SELECT * FROM data")

    checkError(err)
	for rows.Next() {
		var data Data
		err := rows.Scan(&data.id, &data.name)
		checkError(err)
		fmt.Println(data)
	}

		
}