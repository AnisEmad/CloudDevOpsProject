<p align="center">
  <img src="frontend/public/images/nti-logo.png" height="100"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="frontend/public/images/ivolve-logo.png" height="100"/>
</p>

<h1 align="center" style="font-family: 'Poppins', sans-serif; color: #e0e0e0; font-size: 2.8rem;">
   DevOps Project
</h1>

<h3 align="center" style="font-family: 'Poppins', sans-serif; color: #b0bec5;">
  In Collaboration with iVolve Technologies
</h3>

<p align="center" style="max-width: 700px; font-size: 1.1rem; color: #cfd8dc;">
  This project represents the culmination of the DevOps training at the National Telecommunication Institute (NTI),
  in partnership with iVolve Technologies. 
</p>

---

A simple microservices-based web application designed as a DevOps practice project. The application provides user registration and authentication, followed by a main DevOps Roadmap page after successful login. The project is implemented using multiple microservices, with each service responsible for a specific part of the application. The application is containerized using Docker. Each microservice contains its own `Dockerfile` and can be built and deployed independently.

---

## 1. Architecture

The application follows a microservices architecture consisting of:

* **Frontend Service** – Provides the web interface and handles user interaction.
* **Auth Service** – Handles user registration and login.
* **Roadmap Service** – Provides the DevOps Roadmap/main application functionality.
* **MySQL** – Stores user account information.

### High-Level Architecture

```text
                         ┌─────────────────────┐
                         │       Browser       │
                         └──────────┬──────────┘
                                    │
                                    │ HTTP
                                    ▼
                         ┌─────────────────────┐
                         │   Frontend Service  │
                         │      Node.js        │
                         └──────────┬──────────┘
                                    │
                         ┌──────────┴──────────┐
                         │                     │
                         │ HTTP                │ HTTP
                         ▼                     ▼
                ┌─────────────────┐   ┌──────────────────┐
                │   Auth Service  │   │ Roadmap Service  │
                │      Java       │   │     Python       │
                └────────┬────────┘   └──────────────────┘
                         │                      
                         │                      
                         ▼                      
                ┌─────────────────┐   
                │      MySQL      │   
                └─────────────────┘   
```

---

## 2. Services

The project contains three application microservices.

| Service         | Technology              | Responsibility                                 |
| --------------- | ------------------------ | ----------------------------------------------- |
| Frontend        | Node.js / Express / EJS  | Web UI and communication with backend services |
| Auth Service    | Java                      | User registration and authentication           |
| Roadmap Service | Python                    | DevOps roadmap/application data                |

The databases are external dependencies of the microservices.

| Database       | Type       | Used By         | Purpose                         |
| -------------- | ---------- | ---------------- | -------------------------------- |
| MySQL          | Relational | Auth Service     | Stores registered users         |

---

## 3. Frontend Service

The frontend is responsible for providing the user interface.

It contains two main pages:

### Authentication Page

Users can:

* Create an account
* Log in
* Submit their credentials to the Auth Service

### Roadmap Page

After successful authentication, the user is redirected to the main application page containing the DevOps Roadmap.

### Technology

* Node.js
* Express.js
* EJS
* HTML
* CSS

### Directory Structure

```text
frontend/
├── Dockerfile
├── package.json
├── server.js
├── public/
│   ├── css/
│   │   └── style.css
│   └── images/
│       ├── ivolve-logo.png
│       └── nti-logo.png
└── views/
    ├── auth.ejs
    ├── error.ejs
    └── roadmap.ejs
```

### Port

```text
Frontend: 3000
```

The frontend listens for incoming HTTP requests on the configured port.

### Environment Variables

The frontend requires the following environment variables:

```text
AUTH_SERVICE_URL=<AUTH_SERVICE_URL>
ROADMAP_SERVICE_URL=<ROADMAP_SERVICE_URL>
```

Example:

```text
AUTH_SERVICE_URL=http://auth-service:<AUTH_SERVICE_PORT>
ROADMAP_SERVICE_URL=http://roadmap-service:<ROADMAP_SERVICE_PORT>
```

> The actual values should be provided through the deployment environment.

---

## 4. Auth Service

The Auth Service is responsible for user authentication and account management.

It handles:

* User registration
* User login
* Credential validation
* Password storage
* Communication with MySQL

The Auth Service is the **only service that communicates directly with the MySQL database** for user account information.

### Responsibilities

```text
Signup
   │
   ▼
Auth Service
   │
   ▼
MySQL
   │
   ▼
User Created
```

For login:

```text
User
 │
 ▼
Frontend
 │
 ▼
Auth Service
 │
 ▼
MySQL
 │
 ▼
Credentials Validated
```

### Technology

* Java
* Spring Boot
* MySQL

### Port

```text
Auth Service: 5000
```

### Environment Variables

The Auth Service requires database connection information.

```text
DB_HOST=<MYSQL_HOST>
DB_PORT=<MYSQL_PORT>
DB_NAME=<MYSQL_DATABASE>
DB_USERNAME=<MYSQL_USERNAME>
DB_PASSWORD=<MYSQL_PASSWORD>
```

Example:

```text
DB_HOST=mysql
DB_PORT=3306
DB_NAME=ivolve
DB_USERNAME=ibrahim
DB_PASSWORD=pass@123
```

---

## 5. Roadmap Service

The Roadmap Service provides the data and functionality used by the main DevOps Roadmap page.

It is separated from the authentication functionality so that roadmap/application functionality can be developed and deployed independently from user authentication.

### Responsibilities

* Provide roadmap data
* Process roadmap-related requests
* Return roadmap information to the frontend

### Technology

* Python
* Flask/FastAPI

### Port

```text
Roadmap Service: 8080
```

---

## 6. Database Architecture

The application uses MySQL to store user information.

The Auth Service communicates directly with MySQL.

**Database**

```text
ivolve
```

**Table**

```text
users
```

**User Information**

The user database contains information such as:

```text
username
password_hash
```
---

## 7. Service Communication

The frontend acts as the entry point for users.

Backend communication follows this model:

```text
Browser
   │
   ▼
Frontend
   │
   ├──────────────► Auth Service ─────────────► MySQL
   │
   └──────────────► Roadmap Service
```

The frontend does not communicate directly with the databases.

This provides separation between:

* User interface
* Authentication
* Application functionality
* Data storage

---

## 8. Authentication Flow

### User Registration

```text
1. User opens the application.
2. User enters username and password.
3. Frontend receives the registration request.
4. Frontend sends the request to the Auth Service.
5. Auth Service validates the request.
6. Auth Service stores the user in MySQL.
7. Auth Service returns the result to the Frontend.
8. Frontend displays the result to the user.
```

### User Login

```text
1. User enters email and password.
2. Frontend sends the credentials to the Auth Service.
3. Auth Service checks MySQL.
4. Credentials are validated.
5. Auth Service returns the authentication result.
6. Frontend allows the user to access the main application page.
```

---

## 9. API Endpoints

The exact endpoints should match the implementation in each service.

### Auth Service

Typical endpoints:

| Method | Endpoint  | Description                   |
| ------ | --------- | ------------------------------ |
| POST   | `/signup` | Create a new user             |
| POST   | `/login`  | Authenticate an existing user |

Example signup request:

```json
{
  "username": "john@example.com",
  "password": "********"
}
```

Example login request:

```json
{
  "username": "john@example.com",
  "password": "********"
}
```

### Roadmap Service

Typical endpoints:

| Method | Endpoint   | Description                  |
| ------ | ---------- | ------------------------------ |
| GET    | `/roadmap` | Retrieve roadmap information |
| GET    | `/health`  | Service health check         |

> Update this section if the actual API paths differ.

---

## 10. Ports

The following table should be kept synchronized with the application configuration.

| Component       |                     Port | Protocol | Purpose              |
| --------------- | ------------------------: | -------- | --------------------- |
| Frontend        |                    `3000` | HTTP     | Web application      |
| Auth Service    |                    `5000` | HTTP     | Authentication API   |
| Roadmap Service |                    `8080` | HTTP     | Roadmap API          |
| MySQL           |                    `3306` | TCP      | User database        |

---

## 11. Environment Variables

Configuration should be provided through environment variables instead of hardcoding values into the application.

### Frontend

```text
AUTH_SERVICE_URL=<AUTH_SERVICE_URL>
ROADMAP_SERVICE_URL=<ROADMAP_SERVICE_URL>
```

### Auth Service

```text
DB_HOST=<MYSQL_HOST>
DB_PORT=<MYSQL_PORT>
DB_NAME=<MYSQL_DATABASE>
DB_USERNAME=<MYSQL_USERNAME>
DB_PASSWORD=<MYSQL_PASSWORD>
```

---

## 12. Docker

Each microservice has its own Dockerfile.

The services are designed to be containerized independently.

Example repository structure:

```text
project/
│
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── ...
│
├── auth-service/
│   ├── Dockerfile
│   ├── pom.xml
│   └── ...
│
├── roadmap-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── ...
│
└── README.md
```

Each Dockerfile is responsible for:

1. Selecting the required base image.
2. Installing application dependencies.
3. Copying the application source code.
4. Configuring the application.
5. Exposing the required application port.
6. Starting the microservice.

### Building an Image

From a service directory:

```bash
docker build -t <service-name>:latest .
```

Example:

```bash
cd frontend
docker build -t frontend:latest .
```

The same approach can be used for the other services.

---

## 13. Running the Services Independently

Because the services are independent, each service can be built and run separately.

Example:

```bash
docker build -t frontend:latest ./frontend
docker build -t auth-service:latest ./auth-service
docker build -t roadmap-service:latest ./roadmap-service
```

When running the containers, provide the required environment variables.

Example:

```bash
docker run \
  -p <FRONTEND_PORT>:<FRONTEND_PORT> \
  -e AUTH_SERVICE_URL=<AUTH_SERVICE_URL> \
  -e ROADMAP_SERVICE_URL=<ROADMAP_SERVICE_URL> \
  frontend:latest
```

Database services must be available before starting the microservices that depend on them.

---

## 14. Repository Structure

The repository is organized by microservice.

```text
.
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   ├── public/
│   │   └── css/
│   │       └── style.css
│   └── views/
│       ├── auth.ejs
│       ├── error.ejs
│       └── roadmap.ejs
│
├── auth-service/
│   ├── Dockerfile
│   └── ...
│
├── roadmap-service/
│   ├── Dockerfile
│   └── ...
│
└── README.md
```

---
