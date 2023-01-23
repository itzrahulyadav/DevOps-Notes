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

_warning:_To run the script through this method you need to give the permissions  `chmod +x hello-world.sh`.


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

```










