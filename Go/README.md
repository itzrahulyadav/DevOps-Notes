# Go

Go is an open source programming language that makes it easy to build simple,reliable and
efficient software.

Go was designed by google in 2007.

### Packages

Every go program is made up of packages.A Go program
starts running in the main package.

__package__: It is a directory with some code files,which exposes different variables and features.

Go has many builtin packages that can be imported and used just like other programming languages.
One of the most used package is "fmt",which stands for format,and provides input and output functionality.

*The packages can be imported using the `import` keyword*


### First Go program

```Go
// declaring the package as main 
package main

// importing the fmt package
import "fmt"

// execution starts from the main function
func main() {
 fmt.Println("Hello,world!")
}

```
Similar to other programming languages like Java and C++,the `func main()`is the entry point of the program.

#### importing multiple packages

```
import (
    "fmt"
    "math"
    "strings"
)

```

### Variables

Variables are used to store values.

In Go,the `var` keyword is used to declare variables.

`const` can be used to declare constants and must be initialized.Consts value cannot be changed from their 
initial value.

Go also supports short variable declaration using `:=` called syntax sugar.

The `:=` operator automatically defines the variable type based on the value provided.Constants cannot be declared using the `:=` operator.

_example_:

```Go
package main

import "fmt"

func main() {
  // declaration using var keyword
  var num int
  
  // declaration using :=
  number := 2
  
  // declaring the constant
  const pi = 3.14

}

```

### Data types

Go supports following data types

`bool` - used to store Boolean value either `true` or `false`

`int` - integer values.eg- `23`

`float32` - single precision floating point value

`float64` - double precision floating point value

`string` - a text value.eg- `"Go is awesome!"`

`uint` - unsigned integers.eg-`22`


**The data type of the variable can printed using `fmt.Printf("%T",variable)`**

_Note_: ` The variable that are declared without value take the zero value of their type:
0 for numberic types,
false for boolean type,
"" for strings.`

### Taking input

fmt package also allows to take user input.The `Scanln` function present in the fmt package is used to take user input.

_example_:

```Go

var string name

fmt.Scanln(&name)

fmt.Println(name)

```

*The ampersand operator (&) returns the address of the variable*

### if-else statement

The if else statement is used to make decisions and run code based on certain conditions.

```Go
package main

import "fmt"

func main() {
   x := 18
   
   if x < 18 {
     fmt.Println("not allowed to vote")
   }else{
     fmt.Println("eligible to vote")
   }
}

```

Take care of the curly brackets because Go is strict with its syntax.

#### if else-if chain

```Go
package main

import "fmt"

func main() {
   x := "red"
   
   if x == "red" {
     fmt.Println("It is red ")
   }else if x == "blue"{
     fmt.Println("It is blue")
   }else{
     fmt.Println("It is any other colour")
   }
}

```

### Switch statements

Switch statements are used to remove the complex if/else chain of statements.

```Go

x := 3

switch x {
  case 1:
       fmt.Println("one")
  case 2:
       fmt.Println("Two")
  case 3:
       fmt.Println("Three")
  default:
       fmt.Prinln("any other number")
}

```

The default case run when none of the cases are true.

In Go we don't have the break statement because the execution stops when one of the code evaluates to be true.we can use `fallthrough keyword` if we want the next case to evaluate.

### For loops

For loops are the only loop construct in Go.For loops can be used as while loop based on condition.

_example_:

```Go
// this code prints the number from 0 to 9
for i := 0;i < 10;i++ {
   fmt.Println(i)
}

```

Using for loops as while loops.

```Go
i := 0
sum := 0


// this code will calculate the sum of numbers from 0 to 9
for i < 10 {
   sum += i
   i += 1
}


```

### Functions

Functions are block of reusable code which can be called multiple times in the different parts of a program.

The func keyword can be used to define the functions in Go

```Go
// a function without any arguments
func greet() {
   fmt.Println("Hello there 👋🏻")
}

// a function with arguments and a return type
func add(a,b int) int {
     return a + b
}


// invoking the functions inside the main function

func main() {
    greet()
    fmt.Println(add(2,3))
}
```

#### Returning multiple functions from the function

A function can return multiple values. we need to specify the return types in the function definition.

```Go

func add_mul(a, b int) (int, int) {
	   return a + b, a * b
}

func main() {

	 y, x := add_mul(3, 4)
	 fmt.Println(x)
  fmt.Println(y)
 
}

```
#### defer keyword

A defer statement ensures that the function is called only after the surrounding function returns.

```Go


func main() {
	defer greet()
	fmt.Println("I will be printed first")
}

func greet() {
	fmt.Println("Hello 👋🏻")
}

```
In the above code greet function will be called after the main function returns

The deferred statements are executed in last-in-first-out order.

### Pointers

Pointers are variables that hold the memory address of other variable.

In Go we declare pointers using *.

` var p *int`

We can use `&` operator to assign memory address to the pointer.`&`operator returns the
memory address of the variable.

```Go
x := 34
p := &x

fmt.Println(p) //returns the address of x

```

We can access the underlying value of a pointer using the * operator.* operator is called dereferencing operator.


### Struct

Go does not support classes.Instead,it has structs.
Structs are data structure that allows us to group data together.We can group different
type of data together using structs.

```Go
type Car struct {
    name string
    color string
    speed int
}

```
we can now create a new Car using the following syntax:

```Go

supra := Car{"Supra","Blue",350}

// accessing the value using the . operator

fmt.Println(supra.color)

```

#### Methods

Methods are simply functions with special reciever arguments.

```
func (x Car) speed() {
   fmt.Println(x.name)
   fmt.Println(x.speed)
}

supra = Car{"Supra","blue",350}
supra.speed()

```

### Arrays

An array is a fixed size sequence of elements of the same type.

```Go
// array of fixed size 
var arr [5]int 

```
The array elements can be accessed using their index.

### Slices

An array is fixed size,which means once defined it's size can't be changed.To overcome this Go 
provides with dynamic arrays called slices.

```Go

// declaring slices
var arr []int

```

We can also declare slices using the make function

```Go
arr := make(int[],0)
arr = append(arr,4)

```

The elements in the slices can be added using the `append` function.

```Go

 var cars []string
 cars = append(cars,"GTR")
 cars = append(cars,"Mustang")
 
```

### Range 

It is a special form of for loop that allows to iterate over arrays and slices.It returns two values index and the value.

```Go
      arr := []int{2, 3, 3, 2, 5, 6, 74, 4, 3, 3}
       for index, value := range arr {
	   fmt.Println(index, value)
	}

```

### Maps

Maps are used to store key:value pairs.The key needs to be unique.
Maps can be created using couple of ways.

1.Using the `make` function just like slices

```Go
var avengers = make(map[string]int)

avengers["Spiderman"] = 1
avengers["Thor"] = 3

```

2.
```Go
avengers := map[string] int {
    "spiderman":1,
    "Thor":2
}

```
The elements can be deleted using the delete function `delete(avengers,"spiderman")`




