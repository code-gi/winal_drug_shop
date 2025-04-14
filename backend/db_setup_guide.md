# Flask Database Setup Guide

This guide will walk you through the process of setting up, migrating, and populating your Flask database for the Winal Drug Shop application.

## Prerequisites

- Python 3.7+ installed
- Virtual environment created and activated
- Required packages installed from `requirements.txt`

## 1. Initialize the Database

The first step is to initialize your database structure:

```bash
# Make sure you're in the backend directory
cd d:\projects\winal_drug_shop\backend

# Activate your virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
# source venv/bin/activate

# Initialize the database
flask db init
```

This creates a `migrations` directory in your project, which will track all database changes.

## 2. Create the First Migration

Create a migration that will set up your initial database structure:

```bash
# Create a migration script
flask db migrate -m "Initial migration"
```

This creates a migration script in the `migrations/versions` directory that contains the code to create all the necessary tables based on your SQLAlchemy models.

## 3. Apply the Migration

Apply the migration to create the tables in your database:

```bash
# Apply the migration
flask db upgrade
```

This executes the migration script, creating all your database tables.

## 4. Populate the Database

Once the database structure is in place, you can populate it with sample data:

```bash
# Run the population scripts
python populate_db.py
python populate_farm_activities.py
```

These scripts will add:
- Sample categories for medications
- Human and animal medications
- Images linked to medications
- Farm activities and services

## 5. Create an Admin User

Create an admin user to manage the application:

```bash
# Create an admin user
flask create-admin
```

This creates an admin user with the credentials:
- Email: admin@winaldrugshop.com
- Password: Admin123

## Troubleshooting

### Database Already Exists

If you receive an error saying tables already exist:

```bash
# Drop all tables and recreate them
# WARNING: This will delete all data
flask db stamp head
flask db migrate
flask db upgrade
```

### Migration Errors

If you encounter migration errors:

```bash
# Reset the migration
flask db stamp base
flask db migrate -m "Reset migration"
flask db upgrade
```

### Population Script Errors

If you encounter errors during population:

```bash
# Check if data already exists
# The population scripts should check for existing data and skip if found
# You can verify this in your database or modify the scripts to force repopulation
```

## Verification

To verify everything is set up correctly:

```bash
# Run the server
flask run

# Access the API at http://127.0.0.1:5000/
# Try endpoints like /api/medications or /api/auth/login
```

## Notes

- The application uses SQLite by default for development (configured in the `.env` file)
- For production, you should configure PostgreSQL (update the `DATABASE_URL` in `.env`)
- Always back up your database before making significant changes
