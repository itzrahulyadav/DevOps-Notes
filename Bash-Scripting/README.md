## Bash-Scripting

**A bash shell script is a plain text file containing a set of various commands that we usually type in the command line.It can be used to
automate software development tasks such as code compilation,debugging source code,change management and software testing.**

**Bash-Bourne again shell**

### Getting started

Let's start and create a file named `hello-world.sh` and add this code 

```bash
#!/bin/bash

echo "Hello world"
```

The first line of the script `#!/bin/bash` is called **shebang**.It tells the operating system which interpreter to use to run the script.
It instructs the operating system to use bin/bash ,the Bash shell,passing it the script's path as an argument.

Example

`/bin/bash hello-world.sh`

The second line **echo** is a builtin command that writes the arguement it recieves to the standard output.

### executing the script

The script can be executed in couple of ways:

1.

```bash
./hello-world.sh
```

2. 

```bash

bash hello-world.sh
```

_warning:_ To run the script through this method you need to give the permissions  `chmod +x hello-world.sh`.


### variables

A variable is a container for storing values.As the name indicates variables contain a value that can be changed or modified based on the condition or the information passed to the script.

_*Note*: spaces cannot be used around the '=' assignment operator_

_example:_

```bash
#!/bin/bash

#declaring the variable name
name="Rahul"

echo "$name"

#output-Rahul

#reassigning the value to the variable name

name="Supraa"

echo "#name"
#output-Supraa
```

The variables value can be accessed using _*$*_ or _*${}*_.

_example_

```bash
#!/bin/bash

name="Rahul"

echo "$name"
#or echo "${name}".
```

### comments

The comments are added for the readable explanation of the code.
Anything written after the hash sign `#` is considered as comment by the interpreter.Any text written in this line will not be executed.

_example:_

```bash
#!/bin/bash

# this is a comment.
# this is also a comment.

```

### read

The `read`command is used to take input from the user.The way `input()` is used in python or `cin<<` is used in c++.we can use `read` in bash scripting.

_example_:

```bash
#!/bin/bash

echo "enter your name:"
read name

#the user input will be stored in the name variable.

echo "Hello,$name"

```

### Mathematical operations

Just like other programming languages we can perform operations on bash as well.

_example_:

```bash
#!/bin/bash

echo "$(( 2 + 4 ))"

```

#### Arithmetic Operators
- `+` - addition
- `-` - substraction
- `*` - multiplication
- `%` - modulus
- `/` - division


_example_:

```bash
#!/bin/bash

num1=4
num2=5

# addition

echo "$(( num1 + num2 ))"

# substraction

echo "$(( num1 - num2 ))"

# multiplication

echo "$(( num1 * num 2 ))"

# division

echo "$(( num1 / num2 ))"

```

#### Relational Operators

Relational operators allow to make comparisons between the operators.

- `=` - Assignment operator
- `<` or `-lt` - Less than
- `<=`or `-le` - Less than or equal to
- `>` or `-gt` - Greator than
- `>=`or `-ge` - Greator than or equal to
- `!=`- Not equal to

### Logical operators

Logical operators are used to combine multiple conditional statements.The outcome is generally a boolean value i'e either true or false.

- `&&` or `-a`- AND
- `||` or `-o`- OR
- `!` - NOT

_example_

```bash

if [[ 1 -lt 5 && 2 -lt 5 ]];then
  echo "You are right"
else 
  echo "You seem to be incorrect"
fi

```

### Conditional statements

The conditional statements like `if` and 'else' are used to make decisions based on the specified conditions.

_example_:

```bash

name="Rahul"

if [[ $name == "Rahul" ]];then
    echo "hello $name"
else
    echo "Invalid user!"
fi

```

### Switch statement

Switch statement are used to perform tasks based on certain conditions.
It consists of cases which decide the flow of the program.

```bash
#!/bin/bash


echo "enter a number from 1 to 3"
read number

case $number in
	1)
	   echo "You chose 1"
          ;;

	2)
          echo "You chose 2"
          ;;

	3)
          echo "You chose 3"
          ;;
        *)
	        echo "You did not pick a correct number"
          ;;
esac

```


### Iterative statements(loops)

The loops are used to perform a particular task for a certain number of times.
There are three types of loops in Bash and they are `while`,`until` and `for` loop.

#### While Loop

```bash
#!/bin/bash

num=$1

while [ $num -lt 5 ]
do
    echo "$num"
    (( num++ ))
done

```

#### For Loop

```bash
#!/bin/bash

for i in {1..5}
do
   echo $i
done
```

#### Until Loop

```bash
#!/bin/bash

until [[ $choice == "blue" ]]
do
	echo "Pick red or blue"
	read choice
done

echo "you chose blue"
```

_*NOTE*_: We can use break and continue statement to break out of loops based on certain conditions.

_example_:

```bash
#!/bin/bash

for i in {1..10}
do
    if [[ $i == 5 ]];then
       break;
    else
       echo "$i"
    fi
done
```

### Arrays

Arrays are used to store multiple values.We can store multiple values in the same variable and access using the array index

_example_:To access the first element we can do `arr[0]`.The index starts from 0.


```bash
#!/bin/bash

arr=("Rahul" "Peter" "Tony")

echo "The first element of the array is ${arr[0]}"

echo "The whole array is ${arr[@]}"

echo "The length of the array is ${#arr[@]}"

```

### Functions

Functions are block of code which are used to perform particular task and break the entire code into small modules.
Functions make the code more readable and understandable.


_example_:

```bash
func_add ()
{
   local x=$1 # 1st argument to the function
   local y=$2 # 2nd argument  to the function

   result=$(( x + y ))
}

# the function can be called like this

func_add 2 5

```

_Pro Tip_: *Keep practicing to get good at it.*

*Checkout this* [cheatsheet](https://devhints.io/bash) *for more.*





















