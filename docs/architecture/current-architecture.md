# Current Hi.Events Architecture

## Purpose

This document records the baseline architecture of Hi.Events before the Aegis platform redesign.

## Current Deployment

Hi.Events currently uses Docker Compose with three services:

- all-in-one application
- PostgreSQL
- Redis

## Application Container

The all-in-one container runs multiple processes using Supervisor:

- Nginx
- PHP-FPM / Laravel
- Node.js / React SSR
- Laravel Queue Worker
- Laravel Scheduler

Traffic reaches the application through:

localhost:8123 → container port 80 → Nginx

## Data Services

### PostgreSQL

PostgreSQL is the application's primary relational database and stores persistent application data.

### Redis

Redis is configured as the Laravel queue backend.

Background jobs are placed onto Redis and processed by the Laravel queue worker.

## Current Architecture

User
  |
  v
localhost:8123
  |
  v
All-in-One Container
  |
  |-- Nginx
  |-- React / Node SSR
  |-- Laravel / PHP
  |-- Queue Worker
  |-- Scheduler
  |
  +------> PostgreSQL
  |
  +------> Redis

## Baseline Measurements

Initial Docker build time: 407.4 seconds

Application image:
- Docker disk usage: 1.68 GB
- Docker content size: 309 MB

Idle local resource snapshot:
- Application: 3.02% CPU / 473.6 MiB memory
- PostgreSQL: 0.00% CPU / 65.01 MiB memory
- Redis: 0.52% CPU / 10.62 MiB memory

These measurements provide a baseline for later optimisation work.

## Identified Design Consideration

The current all-in-one deployment packages the web application, queue worker and scheduler together.

This is convenient for local deployment, but means these processes cannot be independently deployed or scaled.

The Aegis architecture will evaluate separating these responsibilities when deploying the application to Kubernetes.