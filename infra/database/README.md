# Database - GenAI Email & Report Drafting System

This directory contains the PostgreSQL database schema for the GenAI Email & Report Drafting System.

**Source of truth:** `schema.sql` is the canonical schema definition. Any change must be applied to `schema.sql` first and then reflected in `docs/11_database_schema.md`.

## 📁 Contents

- `schema.sql` - Complete PostgreSQL schema definition with tables, indexes, and comments

## 🗄️ Database Schema

For full schema details (tables, relationships, indexes, constraints, and queries), see `docs/11_database_schema.md`.

## 🚀 Setup Instructions

### Prerequisites

- PostgreSQL 13 or higher installed and running
- Database admin credentials

### Option 1: Using psql (Command Line)

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE genai_email_report;"

# Apply the schema
psql -U postgres -d genai_email_report -f schema.sql
```

### Option 2: Using pgAdmin (GUI)

1. Open pgAdmin
2. Right-click on "Databases" → "Create" → "Database..."
3. Name: `genai_email_report`
4. Click "Save"
5. Right-click on the new database → "Query Tool"
6. Open `schema.sql` and execute

### Verification

After applying the schema, verify the tables were created:

```sql
-- List all tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Count rows in each table (should be 0 for new database)
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM documents;
SELECT COUNT(*) FROM audit_logs;
```

## 🔐 Security Notes

Security considerations are documented in `docs/11_database_schema.md`.

## 🧪 Testing

To test the schema with sample data, see the commented section at the end of `schema.sql`.

## 📚 Integration

The SQLAlchemy models in `backend/models/` mirror this schema structure. Any changes to the schema should be reflected in the models and vice versa.

For Flask-Migrate integration, see `backend/README.md`.

## 🔄 Migrations

For production use, consider using Alembic migrations (via Flask-Migrate) for schema versioning and upgrades. This SQL file serves as the baseline schema for Phase 02.

## 🤝 Contributing

When proposing schema changes:
1. Update `schema.sql`
2. Update corresponding SQLAlchemy models in `backend/models/`
3. Document the change rationale
4. Test with both PostgreSQL and SQLite (for tests)

## 📄 License

See the main repository [LICENSE](../../LICENSE) file.
