
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


## Build your docker image with the name "spring-mvc-sample-image"
docker build . -t spring-mvc-sample-image

## Start a container with the name "spring-mvc-sample-image"
docker run -t --name sample-mvc-sample-container spring-mvc-sample-image