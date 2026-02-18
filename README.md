# SQL Learning Platform

Interactive web application for practicing SQL from basic SELECT queries to advanced database concepts like Views and Triggers.

## Setup
Clone repository

- git clone <repo_url>

- cd sql-learning-platform

Create environment file

- cp .env.example .env

Start application

- docker compose up --build

Application runs at:

- http://localhost:8000

## Core Features
Interactive SQL editor: 
- Automated query evaluation
- MariaDB integration
- Dockerized environment

Automatic Database Sandbox:
- Per-session isolated database
- Cloned from template dataset
- Safe execution filtering

Exercise System:
- Difficulty levels (easy / medium / hard)
- Exercise types:
    select
    dml
    ddl
    temp_table
    procedure
    trigger
- "Show correct solution"
- "Show correct result"

Schema Reference Page:
- Auto-generated table structure
- Column types
- Primary & foreign keys
- Entity relationships overview

Dockerized Architecture:
- MariaDB container
- FastAPI backend
- Environment-based configuration

## Tech Stack
Backend:
- Python (FastAPI / Flask)
- Jinja2 Templates

Frontend:
- CSS

Database:
- MariaDB

Infrastructure:
- Docker

## Architecture Overview
User → FastAPI → Sandbox DB (cloned from template DB)

## Security Considerations
- Server-level destructive commands are blocked
- No root DB access for users
- Each session uses isolated database
- Restricted SQL execution for SELECT-only exercises

## Project Goal
The goal of this project is to create a safe sandbox environment where users can:
- Write SQL queries
- Execute them against an isolated database
- Learn relational database structure
- Understand real-world SQL patterns
- Practice advanced database programming
- Each user session gets its own sandbox database clone to prevent data corruption.

## License

- MIT License

## Status
In development
