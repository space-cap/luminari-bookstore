# Project Overview

This is a Java Spring Boot project named "luminari-bookstore". It appears to be a web application for a bookstore. It is built using Apache Maven.

The project uses the following main technologies:
- **Java 21**
- **Spring Boot 3.5.7**: For building the web application.
- **Spring Data JPA**: For database access.
- **H2 Database**: An in-memory database for development and testing.
- **Lombok**: To reduce boilerplate code.

The main application entry point is the `LuminariApplication` class.

# Building and Running

## Prerequisites
- Java 21
- Apache Maven

## Building the project
To build the project, run the following command in the root directory:
```bash
./mvnw clean install
```

## Running the application
To run the application, use the following command:
```bash
./mvnw spring-boot:run
```

The application will start on the default port (8080).

# Development Conventions

## Testing
The project includes a test class `LuminariApplicationTests` which can be run using the following command:
```bash
./mvnw test
```
