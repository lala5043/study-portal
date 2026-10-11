# 📚 StudyHub — Student Study Notes Sharing Portal

[![Node.js](https://img.shields.io/badge/Node.js-22%20LTS%20%7C%20Latest-brightgreen.svg)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-5.x-lightgrey.svg)](https://expressjs.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-App%20Services%20%26%20Blob%20Storage-0089D6.svg)](https://azure.microsoft.com/)

**StudyHub** is an academic collaboration web application enabling students to discover, upload, categorize, manage, and download verified lecture notes, question papers, presentations, and study materials in one centralized, cloud-backed repository.

---

## 🌟 Key Features & Enhancements

- 🔐 **Authentication & Student Profiles**: Secure user registration, bcrypt password hashing, dynamic avatar badges, and personalized student dashboard.
- ☁️ **Microsoft Azure Blob Storage Integration**: Uploaded study documents are streamed directly to and downloaded from Azure Blob Storage containers, ensuring high availability and zero storage loss.
- 🔄 **Resilient Database Layer**: MySQL2 connection pooling with auto-reconnect, automated table and schema initialization, and Azure Database for MySQL Flexible Server SSL compatibility.
- 📊 **Real-Time Analytics Dashboard**: Real-time counters for platform notes, individual uploads, and total document downloads.
- 🔍 **Advanced Search & Filtering**: Multi-keyword search across titles, subjects, descriptions, and authors; category filtering; and sorting by newest, most downloaded, or alphabetical order.
- 📥 **Live Download Tracking**: Downloads counter increments automatically upon every document download.
- 🛡️ **Ownership Security**: Only the student author or an administrator can edit or delete uploaded study materials.
- 🎨 **Modern Responsive UI**: Clean typography, file format badges (PDF, Word, PPT), true drag-and-drop file upload zone, and animated toast notifications replacing native alert boxes.

---

## 🏗️ Architecture & Workflow

```mermaid
flowchart TD
    Browser["Student Browser (Desktop & Mobile)"] -->|HTTP / REST API| AzureApp["Azure App Service (Node.js Web App)"]
    AzureApp -->|Reverse Proxy / IISNode| Express["Express Backend (backend/server.js)"]
    Express -->|Connection Pool with SSL| MySQL["Azure Database for MySQL Flexible Server"]
    Express -->|@azure/storage-blob SDK| Blob["Azure Blob Storage (Container: studynotes)"]
    Express -->|Static Delivery| Assets["Pages, CSS, JavaScript"]
    GitHub["GitHub Repository"] -->|Automated Actions CI/CD| AzureApp
```

---

## ⚖️ Project Pros & Cons Analysis

### ✅ Pros (Strengths)
1. **Lightweight & High Performance**: Clean vanilla HTML5/CSS/JavaScript with zero bloated frontend framework overhead; loads in milliseconds.
2. **Dedicated Cloud Storage**: Integrates `@azure/storage-blob` SDK for scalable document hosting instead of filling ephemeral server disks.
3. **Resilient Database Architecture**: Connection pooling handles idle timeouts gracefully, avoiding dropped connections.
4. **Automated Schema Provisioning**: Tables and initial seed data are provisioned automatically on initial server startup.
5. **Modern Toast Notifications**: Animated non-blocking toast notifications replace disruptive browser `alert()` dialogs.

### ⚠️ Cons of Original Code & How They Were Resolved
| Original Issue | Resolution Implemented |
| :--- | :--- |
| Notes stored exclusively on local disk (`uploads/`) | Integrated `@azure/storage-blob` SDK with graceful local disk fallback when offline. |
| Single MySQL connection (`createConnection`) dropped on idle | Replaced with `mysql2.createPool` connection pool with auto-reconnect and Azure SSL support. |
| App crashed if database or tables did not exist | Added automated schema & table creation (`CREATE TABLE IF NOT EXISTS`) and demo data seeder. |
| Missing root `package.json` broke GitHub Actions & Azure builds | Added root `package.json` with scripts for `start`, `dev`, `build`, and `test`. |
| Anyone could edit or delete other students' notes | Enforced ownership verification (`user_id` check) on PUT and DELETE endpoints. |
| Download counter in database never incremented | Added `/api/notes/:id/download` route that updates counter before streaming files. |
| Dashboard displayed hardcoded dummy figures | Connected dashboard to live database analytics (`/api/dashboard/stats`). |
| No `.gitignore` (risk of committing `node_modules` and `.env`) | Added comprehensive `.gitignore` safeguarding secrets and dependencies. |

---

## 🚀 Local Quickstart Guide

### 1. Prerequisites
- **Node.js** (v22.x LTS or latest)
- **MySQL Server** (v8.0+ running locally or remotely)
- **Git**

### 2. Configure Environment Variables
Open or create `.env` in the root directory:
```env
PORT=5000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=admin
DB_NAME=studyhub
DB_PORT=3306
DB_SSL=false

# Optional: Microsoft Azure Blob Storage (leave commented to use local /uploads storage)
# AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;AccountName=...;AccountKey=...;EndpointSuffix=core.windows.net
# AZURE_STORAGE_CONTAINER_NAME=studynotes
```

### 3. Install Dependencies & Start Server
```powershell
# From the project root:
npm install

# Start the application:
npm start
```
Open your browser at **`http://localhost:5000`**.

> **Demo Student Account**:
> - Email: `student@studyhub.com`
> - Password: `demo123`

---

## ☁️ Microsoft Azure Deployment Guide

### Step 1: Create Azure Database for MySQL Flexible Server
1. In the **Azure Portal**, search for **Azure Database for MySQL flexible servers** and click **Create**.
2. Configure:
   - Server Name: `studyhub-mysql-server`
   - Compute: Burstable (B1ms is cost-effective)
   - Authentication: MySQL authentication only
   - Admin username & password
3. In **Networking**, enable **Allow public access from any Azure service within Azure to this server**.
4. In **Server parameters**, ensure `require_secure_transport` is set to `ON` (handled by `DB_SSL=true`).
5. Create a database named `studyhub` (the application creates all tables automatically on first run, or you can run `schema.sql`).

---

### Step 2: Create Azure Blob Storage Account
1. In the Azure Portal, create a **Storage Account** (e.g. `studyhubstorage`).
2. Go to **Data storage** -> **Containers** -> click **+ Container**:
   - Name: `studynotes`
   - Anonymous access level: **Blob (anonymous read access for blobs only)** or **Private**
3. Go to **Security + networking** -> **Access keys**.
4. Copy the **Connection string** from `key1`.

---

### Step 3: Create Azure Web App (App Service)
1. In Azure Portal, search for **App Services** -> **Create Web App**:
   - Name: `tybca-group` (or your chosen name)
   - Runtime stack: **Node 22 LTS** (or latest)
   - Operating System: **Linux** or **Windows**
2. In your Web App's left menu, go to **Settings** -> **Environment variables** (Application settings) and add:
   - `PORT`: `8080` (or leave default)
   - `DB_HOST`: `<your-azure-mysql-server>.mysql.database.azure.com`
   - `DB_USER`: `<your-mysql-admin-username>`
   - `DB_PASSWORD`: `<your-mysql-password>`
   - `DB_NAME`: `studyhub`
   - `DB_PORT`: `3306`
   - `DB_SSL`: `true`
   - `AZURE_STORAGE_CONNECTION_STRING`: `<pasted-connection-string-from-step-2>`
   - `AZURE_STORAGE_CONTAINER_NAME`: `studynotes`
3. Click **Apply** to save.

---

### Step 4: Upload to GitHub & Configure Automated CI/CD
1. Initialize Git in the project root:
```bash
git init
git add .
git commit -m "feat: complete StudyHub platform ready for Azure deployment"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/study-portal.git
git push -u origin main
```
2. Download your Web App **Publish Profile**:
   - In Azure Portal, open your Web App overview and click **Get publish profile**.
3. In your GitHub repository:
   - Go to **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**.
   - Name: `AZUREAPPSERVICE_PUBLISHPROFILE`
   - Value: Paste the contents of the downloaded publish profile XML file.
4. GitHub Actions will automatically trigger `.github/workflows/deploy-azure.yml`, build the application, and deploy to your live Azure Web App!

---

## 📡 REST API Reference

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/register` | Register a new student account (`full_name`, `email`, `password`) |
| `POST` | `/api/login` | Authenticate user and receive profile data |
| `GET` | `/api/notes` | Get all notes (supports `?q=`, `?subject=`, `?sort=`, `?user_id=`) |
| `GET` | `/api/notes/:id` | Get details of a single note |
| `POST` | `/api/upload` | Upload study note document to Azure Blob Storage / disk |
| `GET` | `/api/notes/:id/download` | Download file stream and increment downloads counter |
| `PUT` | `/api/notes/:id` | Update note title, subject, or description (owner/admin) |
| `DELETE` | `/api/notes/:id` | Delete note from database and Azure Blob Storage (owner/admin) |
| `GET` | `/api/dashboard/stats` | Retrieve platform and student analytics (`?user_id=`) |
| `POST` | `/api/contact` | Submit student inquiry or feedback message |
| `GET` | `/api/health` | Health check probe for Azure monitoring |

---

## 📄 License
ISC License © 2026 StudyHub Team. Built for students, powered by Microsoft Azure.
#   s t u d y - p o r t a l  
 #   s t u d y - p o r t a l  
 