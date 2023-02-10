# Github Actions


### Workflows 

- Workflow consist of number of actions that occur in a particular order.
- Workflow can be triggered after an event occur in Github.
- A bunch of actions together is called a Job.
- A bunch of Job is called a Workflow.
- A Repository can contain multiple workflows.
- This are stored in the .github/workflow directory.

#### A workflow consists of:

1.name

- It defines the name of the workflow
- It is an optional attribute.

2.on
- It defines the Github event that triggers the workflow,which may be:

          -  Repository events
                - push
                - pull_request
                - release
          -  Webhooks
                - Branch creation
                - issues
                - members
                
          -  Scheduled
                - Cron format
                
- It is a required attribute.

3. job
- It is a block that defines the jobs for the workflow
- Each workflow must have atleast one job.
- Each job must have an  identifier which must start with a letter or underscore
- jobs run in parallel by default.


4. runs-on
- It lets github know the type of machine we would like to use to run  the  job.
- It defines the OS environments called runners where the job will run.
- Each job can run different runner.


5. steps
-  List of actions or commands
-  steps are tasks within a job
-  Access to the file system
-  Each step runs on its own process.
-  steps consist of 

      1. uses
          - identifies an action to use
                  - The could be located in public repository,same repository as the workflow or a docker image registry.
          - Define the location of that action.

      2. run
          - runs commands in the virtual environment's shell

      3. name 
          - an optional identifier of the step.


A simple workflow

```
name: first

on: push

jobs:
  job1:
      name: First job
      runs-on: ubuntu-latest
      steps:
      - name: Step one
        uses: actions/checkout@v2
      - name: Step two
        run: env | sort
  job2:
      name: Second job
      runs-on: windows-latest
      steps:
      - name: Step one
        uses: actions/checkout@v2
      - name: Step two
        run: "Get-ChildItem Env: | Sort-Object Name"
    
```

- Adding dependencies 

we can use need attribute to add the dependencies between the jobs

needs:Identifies one or more jobs that must complete successfully before a job will run.

```
jobs:
   job1:
   job2:
   job3:
      needs: [job1,job2]
```
In the example above job 3 depends on job1 and job2 to run successfully.

- Conditionals

This are used to specify the tasks based on the condition
For this we need to create a new block



### Using the actions from the Github marketplace

-  The actions in the GitHub Marketplace are pre-built scripts that can be used to automate a wide range of tasks, from building and testing code, to deploying applications, to managing your workflows and projects.


### Using the actions from a Repository

- Actions can be used from workflow's repo

```
steps:
     - uses: "./github/action1"

```
- From any public repository

```
steps:
     - uses: "user/repo@ref"
```
- Docker images from an image registry
- Specify the "docker://" path to the image and tag
- Docker hub is used by default


```
steps:
     -uses: "docker://image:tag"
```

### Passing arguments to an action
- steps use the `with` attribute to pass argument
- With creates a new block for mapping arguments to inputs


syntax:

```
steps:
     - name: Checkout the code
     uses: actions/checkout@v3
     with:
          key:value
          key:value
          
```

### Passing environment variables

- Environment variables are dynamic key value pair stored in the memory.
- Environment variables are not already stored in the memory rather they are injected when the process starts
- This are case sensitive
- We can define our own environment variables  in `env` attribute.
- The env can be defined in the workflow,jobs or steps level.

_Scope_ of the variables

1. If the variables are declared at the workflow level they can be accessed by all jobs,steps,all actions and all commands.
2. If the variables are declared at the jobs level they can be accessed by all steps,all actions and commands within the job.
3. If the variables are declared at the steps level they can be accessed by all the step.


#### Accessing the env variables

The variable can be accessed by two ways:
- Shell variable syntax

      1. Bash (Linux/macOS) - `$VARIABLE_NAME`      
      2. Powershell (Windows) - `$Env:VARIABLE_NAME` 
          
- YAML syntax - `- ${{ env.VARIABLE_NAME }}`


example:

```YAML

name: Environment Variables
env:
    MY_ENVIRONMENT_VARIABLE: 'Hello there :)'
    
on: [push]
jobs:
    first-job:
          runs-on: ubuntu-latest
          steps:
            - name: Print env variable
              run: | 
                 echo "$MY_ENVIRONMENT_VARIABLE"
```


### Using secrets in the workflow
Sometimes we need to store passwords,API keys etc in the workflows

- Secrets are stored in the github repository settings.
- Can't be viewed or edited once created
-  Workflows can have up to 100 secrets
-  Secrets limited to 64 KB

To access the secret 

```

${{ secrets.SECRET_NAME }}

```
Secrets can be passed as env variables or parameters

### Artifacts

- Artifacts are data preserved from a workflow.
- They may be files or collection of files like archieves,log files

Artifacts can be used to pass data between workflows jobs.

For example suppose there are two jobs where second job needs a file which is created by first job.

Job 1 - Creates and upload artifact
Job 2 - Wait for the Job 1 to complete and then download and use the artifact

- Artifacts can only be uploaded by a workflow using `actions/upload-artifact`

- And can only be downloaded by the uploading workflow using `actions/download-artifact`

- Artifacts are by default stored for 90 days.

_example_:

```
name: Artifact

on: [push]

env:
   ARTIFACT_NAME: myartifact
   
jobs:
   main:
      runs-on: ubuntu-latest
      steps:
         - name: checkout the code
           uses: actions/checkout@v2
         - name: upload the artifact
           uses: actions/upload-artifact@v2
           with:
               name: ${{ env.ARTIFACT_NAME }}
               path: .
               
```


### Managing PR's using the github actions

Github actions can be use to 

- Automatically approve and merge the PR's based on criteria
- Run automated tests to check the code in the PR
- Check the username that submitted the PR
- Approve and merge the PR
- Delete the branch associated with the PR

