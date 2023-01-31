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




