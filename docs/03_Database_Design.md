# CareerOS AI - Database Design

**Version:** 1.0
**Database:** PostgreSQL 16

---

# 1. Database Philosophy

The database is designed using normalization principles to minimize data duplication while maintaining scalability and performance.

Each table has a single responsibility and represents one business concept.

---

# 2. Core Modules

## Identity

### users

Stores authentication and account information.

### user_profiles

Stores personal profile details.

---

## Career

### resumes

Stores resume metadata.

### resume_sections

Stores sections belonging to a resume.

### education

### experience

### projects

### certifications

### skills

---

## Company

### companies

### company_salary

### hiring_process

### company_technologies

---

## Interview

### interview_categories

### interview_questions

### interview_answers

---

## Learning

### learning_paths

### learning_modules

### user_learning_progress

---

## AI

### recommendations

### resume_reviews

### career_advice

---

## Analytics

### dashboard_statistics

### activity_logs

---

# 3. Naming Conventions

* Use lowercase table names.
* Use snake_case.
* Primary key: id
* Foreign key format: table_name_id
* Timestamp columns:

  * created_at
  * updated_at

---

# 4. Relationships

User
├── Profile
├── Resume
│      ├── Education
│      ├── Experience
│      ├── Skills
│      ├── Projects
│      └── Certifications
│
├── Learning Progress
│
├── Recommendations
│
└── Activity Logs

Company
├── Salary
├── Hiring Process
└── Technologies

Learning Path
└── Learning Modules

Interview Category
└── Interview Questions

---

# 5. Database Goals

* Third Normal Form (3NF)
* Strong referential integrity
* Future-proof design
* Efficient indexing
* Soft delete support where appropriate
* Audit-friendly timestamps
