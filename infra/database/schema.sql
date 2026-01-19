-- PostgreSQL Schema for GenAI Email & Report Drafting System
-- Phase 02 - Database Schema & Persistence
-- This schema defines tables for users, documents, and audit logging

-- Drop existing tables if they exist (development only)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- Users Table
-- ============================================================================
-- Stores user authentication information and role-based access control
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for efficient user lookups
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- ============================================================================
-- Documents Table
-- ============================================================================
-- Stores AI-generated documents (emails and reports) with metadata
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    doc_type VARCHAR(50) NOT NULL,
    title VARCHAR(500),
    prompt_input TEXT,
    content TEXT NOT NULL,
    tone VARCHAR(50) NOT NULL,
    structure VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint with cascade delete
    CONSTRAINT fk_documents_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- Indexes for efficient document queries
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_created_at ON documents(created_at DESC);
CREATE INDEX idx_documents_user_created ON documents(user_id, created_at DESC);

-- ============================================================================
-- Audit Logs Table
-- ============================================================================
-- Tracks system actions and events for compliance and traceability
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    request_context_id VARCHAR(100),
    details TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint with SET NULL on delete
    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);

-- Indexes for efficient audit log queries
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_user_created ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_action_created ON audit_logs(action, created_at DESC);
CREATE INDEX idx_audit_logs_request_context ON audit_logs(request_context_id);

-- ============================================================================
-- Comments
-- ============================================================================

-- Users Table:
--   - id: Auto-incrementing primary key
--   - username: Unique username for login (indexed for fast lookup)
--   - email: Unique email address (indexed for fast lookup)
--   - password_hash: Hashed password (never store plain text)
--   - role: USER or ADMIN for role-based access control
--   - created_at: Timestamp of account creation

-- Documents Table:
--   - id: Auto-incrementing primary key
--   - user_id: Foreign key to users (CASCADE DELETE: when user is deleted, their documents are also deleted)
--   - doc_type: Type of document (email or report)
--   - title: Optional title or subject line
--   - prompt_input: Sanitized user input/context (optional, for audit purposes)
--   - content: The generated document content
--   - tone: Tone used for generation (professional, casual, formal, friendly)
--   - structure: Structure type for reports (executive_summary, detailed, bullet_points)
--   - created_at: Timestamp of document generation
--   - Composite index (user_id, created_at) for efficient user history queries

-- Audit Logs Table:
--   - id: Auto-incrementing primary key
--   - user_id: Foreign key to users (SET NULL on DELETE: preserve logs even if user is deleted)
--   - action: Action performed (e.g., 'generate_email', 'generate_report', 'login')
--   - entity_type: Type of entity affected (e.g., 'document', 'user')
--   - entity_id: ID of affected entity (optional)
--   - request_context_id: Unique request/session identifier for correlation
--   - details: Additional context as text (optional)
--   - created_at: Timestamp of the action
--   - Multiple indexes for different audit query patterns

-- ============================================================================
-- Access Patterns
-- ============================================================================

-- 1. User Document History (most common query):
--    SELECT * FROM documents WHERE user_id = ? ORDER BY created_at DESC;
--    -> Optimized by idx_documents_user_created

-- 2. Admin View All Documents:
--    SELECT * FROM documents ORDER BY created_at DESC;
--    -> Optimized by idx_documents_created_at

-- 3. User Audit History:
--    SELECT * FROM audit_logs WHERE user_id = ? ORDER BY created_at DESC;
--    -> Optimized by idx_audit_logs_user_created

-- 4. System-wide Audit Logs:
--    SELECT * FROM audit_logs ORDER BY created_at DESC;
--    -> Optimized by idx_audit_logs_created_at

-- 5. Action-based Audit Query:
--    SELECT * FROM audit_logs WHERE action = ? ORDER BY created_at DESC;
--    -> Optimized by idx_audit_logs_action_created

-- 6. Request Context Correlation:
--    SELECT * FROM audit_logs WHERE request_context_id = ?;
--    -> Optimized by idx_audit_logs_request_context

-- ============================================================================
-- Sample Data (Optional - for testing)
-- ============================================================================

-- Uncomment to insert sample data:
/*
-- Insert sample user
INSERT INTO users (username, email, password_hash, role)
VALUES ('admin', 'admin@example.com', 'hashed_password_here', 'ADMIN');

-- Insert sample document
INSERT INTO documents (user_id, doc_type, title, content, tone)
VALUES (1, 'email', 'Welcome Email', 'Dear user, welcome to our system!', 'professional');

-- Insert sample audit log
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, request_context_id)
VALUES (1, 'generate_email', 'document', 1, 'req-12345');
*/

-- ============================================================================
-- End of Schema
-- ============================================================================
