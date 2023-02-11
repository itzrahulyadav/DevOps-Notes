## How to create your own custom actions.

One of the main advantage of using GitHub actions is that GitHub provides with a large number of prebuilt actions which are
super easy to use in our workflows.But did you know that you can create your own custom action to satisfy your need.

In this article I will share how you can create your own custom GitHub action and share it in the GitHub marketplace.

So without any further ado let's hop in.


### Understanding what are actions

If you have used GitHub actions even a little,you must have used actions in your jobs.So what actually are actions?
Actions are scripts that perform a specific task like checking the code,building the code,publishing packages etc.Actions allow us to
perform specific tasks in repeatable manner without us having to write the code again and again.

One of the popular action is  `actions/checkout@v3` which is used to checkout the code from our repository so that the workflow can
access it.

Components of an action
An action typically consists of:

1. Dockerfile
     -  Dockerfile installs libraries
     -  It also calls the action Script.
     -
2. Script
    -  It defines command that are run by the action
    -  It interacts with the environment variables
    -  It can be written in any Scripting language.
 
3.  action.yml file
    -  It is used to provide name to our custom action.
    -  It also provides the description about our action.
    
4. A README.md file
   -  It is used to describe what our action does and is needed to put the action in GitHub marketplace
   -  It provides information about the env variables being used,explains arguments etc.


So,now that we know what actions are and what they are composed of ,let's create our own simple custom action.


### Step 1. Create a git repository
- Create a new gitHub repository and add Dockerfile and entrypoint.sh file

- Your repository should look like this after this step:

![Screenshot (91)](https://user-images.githubusercontent.com/65400893/218271476-ced58543-69c6-41f5-bb1c-d57b9f997289.png)


- Add the following code in your Dockerfile

 ```bash
  
FROM ubuntu
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

 ```
 
 - Add the following code in your entrypoint.sh file

```
#!/bin/bash

echo "Hello,I am a custom action"
```

our custom GitHub action prints "Hello,I am a custom action" texts on the screen.

### Now we are ready to use our custom action.

Now let's move to the github repository where you want to use it.

-  Create a `.github` folder and inside that folder create a workflows folder
-  Inside the workflows folder create a file with `.yml` or `.yaml` extension.

![Screenshot (93)](https://user-images.githubusercontent.com/65400893/218271973-13c53864-0585-4e46-a942-fe20536355f5.png)




-  Add the following code to the file


```

name: Testing our custom GitHub Action

on:
   push:
      branches: main
      
jobs:
    main:
       runs-on: ubuntu-latest
       steps:
         - uses : actions/checkout@v2
           # We can use our custom action using the following syntax -  `uses:<githubaccount_owner>/<github_repo>@<github-branch>`
         - uses : <github_repo_owner_name>/<Github_repo_name>@<branch> 


```

- Click on the commit button and go to the actions tab you would see that our action is working perpectly.

![Screenshot (94)](https://user-images.githubusercontent.com/65400893/218271554-5ab72502-2843-4858-bfb6-accfd9f78c5d.png)

