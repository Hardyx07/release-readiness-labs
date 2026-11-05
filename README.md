# OrderFlow

This repository contains the Release Readiness Investigation & Deployment Approval Lab.

## Application

A simple Node.js Express application.

### Endpoints
- `GET /`
- `GET /health`

## Current Release

| | |
|---|---|
| Version | **v2.3.0** |
| Environment | production |
| Image | `lab-app:v2.3.0` |
| Status | Ready for production |

Release documentation:
- [Release Readiness Pack](docs/RELEASE_READINESS.md)
- [Rollback plan](release/rollback.yml)
- [Approvals](release/approvals.yml)
- [Release summary](release/release-summary.yml)

## Getting Started

### Clone
```bash
git clone https://github.com/kalviumcommunity/release-readiness-labs.git
cd release-readiness-labs
```

### Install
```bash
cd app
npm install
```

### Run
```bash
npm start
```
Alternatively, use Docker Compose:
```bash
docker-compose up --build
```

### Push
Make your changes and push them back to the repository.

## Repository Structure
```
├── .github/
│   └── workflows/
│       └── release.yml
├── app/
│   ├── server.js
│   └── package.json
├── deployment/
│   ├── kubernetes/
│   └── terraform/
├── release/
├── scripts/
├── Dockerfile
├── docker-compose.yml
└── README.md
```
