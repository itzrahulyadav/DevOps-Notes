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

```
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

