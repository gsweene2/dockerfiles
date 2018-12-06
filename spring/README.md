
# How to Build the Project, the Image, and run a Container with the image

## Set up your Dockerfile inside your project directory
```
.
├── Dockerfile
├── README.md
├── mvnw
├── mvnw.cmd
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── hello
    │   │       ├── Application.java
    │   │       └── GreetingController.java
    │   └── resources
    │       ├── static
    │       │   └── index.html
    │       └── templates
    │           └── greeting.html
    └── test
        └── java
            └── hello
                └── ApplicationTest.java

```

## Build the Project
Why? This creates the /target directory with the artifact we will reference in our Dockerfile to build the image

Prerequisite: Install java, install maven
```
java -version
mvn --version
mvn clean install
```

## Build your docker image with the name "spring-mvc-sample-image"
```
docker build . -t spring-mvc-sample-image
```

## Start a container with the name "spring-mvc-sample-image"
```
docker run -t --name sample-mvc-sample-container spring-mvc-sample-image
```

## Tag & Push the Image to DockerHub

First, list the image and find the one you built
```
$ docker images

REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
spring-mvc-sample-image   latest              8fa27ad00edd        34 minutes ago      540MB
```

Next, tag the image
```
docker tag 8fa27ad00edd gsweene2/spring-mvc-sample-image:0.1
```

Finally, push!
```
docker push gsweene2/spring-mvc-sample-image:0.1
```