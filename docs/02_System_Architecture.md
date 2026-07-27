# CareerOS AI - System Architecture

**Version:** 1.0
**Status:** Draft

---

# 1. Architecture Style

CareerOS AI follows a **Modular Monolith Architecture**.

This architecture allows the application to remain a single deployable backend while organizing business logic into independent domains. It provides the simplicity of a monolith and prepares the project for future microservice extraction if required.

---

# 2. Technology Stack

Backend

* Java 21
* Spring Boot
* Spring Security
* Spring Data JPA
* Hibernate
* Maven

Database

* PostgreSQL

Mobile

* Flutter

Infrastructure (Future)

* Docker
* Redis
* Kafka
* AWS
* Kubernetes
* Nginx

---

# 3. High-Level Architecture

```text
Flutter Mobile
       │
 REST API (HTTPS)
       │
Spring Boot Backend
       │
──────────────────────────────
Identity Module
Career Module
Company Module
Interview Module
Learning Module
Recommendation Module
Analytics Module
──────────────────────────────
       │
 PostgreSQL Database
```

---

# 4. Domain Modules

## Identity

Responsible for user accounts, authentication, authorization, roles, and profiles.

---

## Career

Responsible for resumes, skills, education, experience, and projects.

---

## Company

Responsible for company information, hiring process, salary insights, and technologies.

---

## Interview

Responsible for HR interview preparation and technical interview preparation.

---

## Learning

Responsible for learning roadmaps, progress tracking, and study plans.

---

## Recommendation

Responsible for AI-powered recommendations based on user profile and progress.

---

## Analytics

Responsible for dashboards, statistics, and career insights.

---

# 5. Architectural Principles

* Modular Monolith
* Package-by-Feature
* Layered Architecture
* SOLID Principles
* DTO Pattern
* Repository Pattern
* Service Layer
* Global Exception Handling
* Validation
* Secure by Default

---

# 6. Future Scalability

The architecture should allow future extraction of modules into independent microservices without major code rewrites.

Potential future services include:

* Authentication Service
* Recommendation Service
* Analytics Service
* Notification Service

---

# 7. Non-Functional Requirements

* Security
* Maintainability
* Scalability
* Performance
* Readability
* Testability
* Clean Code
* Professional Documentation
