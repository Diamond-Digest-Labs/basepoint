## 🚀 Quick Start: Environment Setup

To protect our "Data-Driven Meritocracy," we strictly decouple configuration from code. All sensitive credentials (Neon DB, API keys) must reside in a local `.env` file which is ignored by Git.

### 1. Initialize your Environment

Copy the template below into a new file named `.env` in the root directory:

```ini
# --- Basepoint Environment Configuration ---
# DO NOT COMMIT THIS FILE TO VERSION CONTROL

# Neon PostgreSQL (Cloud-Native Infrastructure)
NEON_HOST=your_project_id.region.aws.neon.tech
NEON_DB=neondb
NEON_USER=alex_the_architect
NEON_PASS=your_secure_password_here
NEON_PORT=5432

# Analytical Engine & Environment
R_ENV=development  # options: development, staging, production
BASEPOINT_VERSION=1.0.0


```

### 2. Dependency Management

We use `renv` to ensure any future production environments remain identical.

* Run `renv::restore()` to install the exact versions of R packages (dplyr, janitor, RPostgres) used in this project.

---

## 🌿 Branching & Development Workflow

We follow a **Feature-Based Branching** model. All work must be isolated before being merged into the "Source of Truth" (`main`).

### Branch Naming

* `feat/` : New logic or UI components (e.g., `feat/radar-charts`)
* `fix/` : Bug fixes (e.g., `fix/csv-parsing-error`)
* `refactor/` : Code cleanup without functional changes.

---

## 🏗 The Architectural Standard

### Data Ingestion Layer

When working with raw GameChanger CSVs (like the Thika Rangers 163-column export), always use the `clean_data.R` functions. We do not perform "ad-hoc" cleaning in the console; all transformations must be **Reproducible**.

### Security Protocol

1. **Zero Secrets in Code:** If you see a hardcoded password or API key, it is a critical architectural failure. Use `Sys.getenv("KEY_NAME")`.
2. **Encrypted Handshakes:** All database connections must use `sslmode = "require"`.

---

## 🚢 Pull Request (PR) Requirements

Before merging, your PR must:

1. Pass all local R/Go build tests.
2. Include an updated `renv.lock` if new packages were added.
3. Be reviewed and "Approved" by the Lead Architect.

---

### Architect's Note for the Team

> *"Your `.env` file is your personal key to the city. Keep it safe. Your code is our collective legacy. Keep it clean."*

---

