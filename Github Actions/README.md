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
