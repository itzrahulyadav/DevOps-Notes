## Jenkins

- Jenkins is an open source automation server
- It helps to automate the software development activities related to building,testing
and deploying ,facilitating continuous integration and continuous delivery.

- Jenkins helps in the CI(continuous integration)

#### Continuous Integration

It is the practice of automating the integration of code changes from multiple contributors into a single software project,allowing developers to frequently merge code changes into a central repository where builds and tests are then run.


##### Resources

- [Installation guide (official website)](https://www.jenkins.io/doc/book/installing/)

- [Jenkins FreeCodeCamp (video)](https://youtu.be/f4idgaq2VqA)



## Jenkins UI
![Screenshot (81)](https://user-images.githubusercontent.com/65400893/216839683-4947b295-8050-4b4b-9114-c885cf445e38.png)



## Jenkins pipeline

- A jenkins pipeline is a suite of plugins which supports implementing and integrating continuous delivery pipelines into Jenkins

- A continuous delivery pipeline is an automated expression of your process for getting software from version control right through to your users and customers.

- The definition of Jenkins pipeline is typically written into a text file called Jenkinsfile which in turn is checked into a project's source control repository.


## Jenkinsfile

A Jenkinsfile is a text file that defines the pipeline as code in Jenkins. It is written in the Groovy programming language and is used to specify the steps involved in building, testing, and deploying software projects. The Jenkinsfile is typically stored in the source code repository of the software project and is executed by Jenkins when a build is triggered.


- ##### There are two types of Jenkinsfile
      
1. Declarative Pipelines

This type of Jenkinsfile uses a simpler, more structured syntax that provides a high-level, automated way to define the steps involved in the software development process. It is recommended for users who want a straightforward, easier-to-read syntax for defining their pipelines.

syntax:

```
pipeline {
    agent {
        label 'label-name'
    }
    stages {
        stage('Build') {
            steps {
                echo "Building"
                sh ```
                 echo "doing build stuff"
                ```
            }
        }
        stage('Test') {
            steps {
                echo "Testing"
                sh ```
                 echo "doing test stuff"
                ```
            }
        }
    }
}


```

- The pipeline starts with the pipeline block, which defines the start of the pipeline. The agent block specifies the agent that will be used to run the pipeline, using the label attribute to specify the label name.

The stages block contains multiple stage blocks, each defining a separate stage in the pipeline. The steps block within each stage contains the steps that will be executed in that stage.

In this example, there is two stage: Build. The build steps go in the Build stage and Test .The test steps go there.


2. Scripted Pipeline

- This type of Jenkinsfile uses the Groovy programming language to define the steps involved in the software development process. It provides more control and flexibility over the pipeline compared to Declarative Pipelines, and is recommended for users who require complex logic in their pipelines or want to reuse code from existing scripts.


syntax:

```Jenkinsfile

node {
    stage('Build') {
        // build steps go here
    }
    stage('Test') {
        // test steps go here
    }
    stage('Deploy') {
        // deploy steps go here
    }
}

```

- In this example, the Jenkinsfile starts with the node block, which specifies the node that will be used to run the pipeline.

The pipeline then defines three stages: Build, Test, and Deploy. The build steps go in the Build stage, the test steps go in the Test stage, and the deploy steps go in the Deploy stage.




## Triggers

Triggers in Jenkins are events that initiate the execution of a pipeline. Triggers can be based on a variety of events, such as changes in source code repositories, scheduled builds, or manually initiated builds.

 common types of triggers in Jenkins:
 
 1.SCM Triggers: Triggers a build when changes are detected in a source code repository, such as Git or SVN. This is a common way to implement continuous integration (CI).
 
2.Timer Triggers: Triggers a build at a specific time or interval, such as daily or weekly builds.
  - It's like a cron job in linux.
