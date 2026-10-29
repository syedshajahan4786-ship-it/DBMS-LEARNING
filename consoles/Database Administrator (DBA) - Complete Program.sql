-- connection: 6ae2bc4d1c1a39f2ed432423

-- ============================================================
-- DATABASE ADMINISTRATOR (DBA) - COMPREHENSIVE PROGRAM
-- Demonstrates all 10 DBA responsibilities through SQL operations
-- ============================================================

-- ============================================================
-- TASK 1: DEFINE THE ROLE OF A DBA
-- A DBA manages, maintains, secures, and ensures reliable
-- operation of an organization's database systems
-- ============================================================

-- ============================================================
-- TASK 2: DATABASE DESIGN AND IMPLEMENTATION
-- DBA creates and configures database structures
-- ============================================================

-- Create a sample organizational database
CREATE DATABASE IF NOT EXISTS OrganizationDB;

-- Use the database
-- USE OrganizationDB;  -- Uncomment for MySQL

-- 2.1 Create tables with proper design
CREATE TABLE Department (
    Department_ID       INT PRIMARY KEY,
    Department_Name     VARCHAR(50) NOT NULL UNIQUE,
    Location            VARCHAR(100) NOT NULL,
    Budget              DECIMAL(12, 2) CHECK (Budget >= 0),
    Created_Date        DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Employee (
    Employee_ID         INT PRIMARY KEY,
    Employee_Name       VARCHAR(50) NOT NULL,
    Email               VARCHAR(100) UNIQUE NOT NULL,
    Phone               VARCHAR(15),
    Hire_Date           DATE NOT NULL,
    Salary              DECIMAL(10, 2) CHECK (Salary > 0),
    Department_ID       INT,
    CONSTRAINT FK_Emp_Dept FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID)
        ON DELETE SET NULL
);

CREATE TABLE Project (
    Project_ID          INT PRIMARY KEY,
    Project_Name        VARCHAR(100) NOT NULL,
    Start_Date          DATE NOT NULL,
    End_Date            DATE,
    Budget              DECIMAL(12, 2) CHECK (Budget >= 0),
    Status              VARCHAR(20) CHECK (Status IN ('Planning', 'Active', 'Completed', 'Cancelled')),
    Department_ID       INT,
    CONSTRAINT FK_Proj_Dept FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID)
);

CREATE TABLE Assignment (
    Employee_ID         INT,
    Project_ID          INT,
    Role                VARCHAR(50),
    Hours_Per_Week      INT CHECK (Hours_Per_Week > 0 AND Hours_Per_Week <= 60),
    Assigned_Date       DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (Employee_ID, Project_ID),
    CONSTRAINT FK_Assign_Emp FOREIGN KEY (Employee_ID)
        REFERENCES Employee(Employee_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Assign_Proj FOREIGN KEY (Project_ID)
        REFERENCES Project(Project_ID)
        ON DELETE CASCADE
);

-- 2.2 Insert sample data
INSERT INTO Department VALUES
(10, 'Human Resources', 'Building A', 500000.00, '2020-01-15'),
(20, 'Information Technology', 'Building B', 1200000.00, '2020-01-15'),
(30, 'Finance', 'Building C', 800000.00, '2020-01-15'),
(40, 'Marketing', 'Building D', 600000.00, '2020-01-15');

INSERT INTO Employee VALUES
(1001, 'Rajesh Kumar', 'rajesh@org.com', '9876543201', '2020-03-10', 75000.00, 10),
(1002, 'Priya Sharma', 'priya@org.com', '9876543202', '2020-04-15', 95000.00, 20),
(1003, 'Amit Patel', 'amit@org.com', '9876543203', '2021-01-20', 85000.00, 20),
(1004, 'Sneha Reddy', 'sneha@org.com', '9876543204', '2021-06-01', 70000.00, 30),
(1005, 'Vikram Singh', 'vikram@org.com', '9876543205', '2022-02-15', 80000.00, 40);

INSERT INTO Project VALUES
(5001, 'HR Portal Redesign', '2026-01-01', '2026-06-30', 150000.00, 'Active', 10),
(5002, 'Cloud Migration', '2026-03-01', '2026-12-31', 500000.00, 'Active', 20),
(5003, 'Financial Dashboard', '2026-02-01', '2026-08-31', 200000.00, 'Active', 30),
(5004, 'Marketing Campaign', '2026-04-01', '2026-09-30', 180000.00, 'Planning', 40);

INSERT INTO Assignment VALUES
(1001, 5001, 'Project Manager', 20, '2026-01-05'),
(1002, 5002, 'Lead Developer', 35, '2026-03-10'),
(1003, 5002, 'Database Engineer', 30, '2026-03-15'),
(1004, 5003, 'Financial Analyst', 25, '2026-02-10'),
(1005, 5004, 'Marketing Coordinator', 40, '2026-04-05');

-- ============================================================
-- TASK 3: DATABASE SECURITY AND USER ACCESS CONTROL
-- DBA creates users, roles, and manages privileges
-- ============================================================

-- 3.1 Create database users (PostgreSQL syntax)
-- CREATE USER hr_manager WITH PASSWORD 'hr_secure_pass';
-- CREATE USER it_admin WITH PASSWORD 'it_secure_pass';
-- CREATE USER finance_analyst WITH PASSWORD 'finance_secure_pass';
-- CREATE USER readonly_user WITH PASSWORD 'read_secure_pass';

-- 3.2 Create roles for privilege management
-- CREATE ROLE hr_role;
-- CREATE ROLE it_role;
-- CREATE ROLE finance_role;
-- CREATE ROLE readonly_role;

-- 3.3 Grant privileges to roles
-- HR Role: Full access to HR-related tables
-- GRANT SELECT, INSERT, UPDATE, DELETE ON Employee TO hr_role;
-- GRANT SELECT ON Department TO hr_role;

-- IT Role: Full access to IT-related tables
-- GRANT SELECT, INSERT, UPDATE, DELETE ON Project, Assignment TO it_role;
-- GRANT SELECT ON Employee, Department TO it_role;

-- Finance Role: Read access to financial data
-- GRANT SELECT ON Department, Employee TO finance_role;
-- GRANT SELECT ON Project TO finance_role;

-- Readonly Role: Select only
-- GRANT SELECT ON ALL TABLES IN DATABASE OrganizationDB TO readonly_role;

-- 3.4 Assign roles to users
-- GRANT hr_role TO hr_manager;
-- GRANT it_role TO it_admin;
-- GRANT finance_role TO finance_analyst;
-- GRANT readonly_role TO readonly_user;

-- 3.5 Revoke privileges (when needed)
-- REVOKE DELETE ON Employee FROM hr_role;
-- REVOKE ALL PRIVILEGES ON Department FROM readonly_role;

-- ============================================================
-- TASK 4: BACKUP AND RECOVERY MANAGEMENT
-- DBA implements backup strategies to protect data
-- ============================================================

-- 4.1 Full database backup (PostgreSQL)
-- pg_dump OrganizationDB > backup_full_20261029.sql

-- 4.2 Schema-only backup
-- pg_dump -s OrganizationDB > backup_schema_20261029.sql

-- 4.3 Data-only backup
-- pg_dump -a OrganizationDB > backup_data_20261029.sql

-- 4.4 Table-specific backup
-- pg_dump -t Employee OrganizationDB > backup_employee_20261029.sql

-- 4.5 Compressed backup
-- pg_dump OrganizationDB | gzip > backup_20261029.sql.gz

-- 4.6 Restore from backup
-- psql OrganizationDB < backup_full_20261029.sql

-- 4.7 Point-in-time recovery (requires WAL archiving)
-- Restore base backup, then apply WAL logs up to specific timestamp

-- 4.8 Create backup verification query
SELECT 'Backup verification: ' || COUNT(*) || ' departments' AS Verification
FROM Department
UNION ALL
SELECT 'Backup verification: ' || COUNT(*) || ' employees'
FROM Employee
UNION ALL
SELECT 'Backup verification: ' || COUNT(*) || ' projects'
FROM Project;

-- ============================================================
-- TASK 5: PERFORMANCE MONITORING AND OPTIMIZATION
-- DBA monitors and optimizes database performance
-- ============================================================

-- 5.1 Create indexes for performance optimization
CREATE INDEX idx_employee_dept ON Employee(Department_ID);
CREATE INDEX idx_employee_email ON Employee(Email);
CREATE INDEX idx_project_status ON Project(Status);
CREATE INDEX idx_project_dept ON Project(Department_ID);
CREATE INDEX idx_assignment_emp ON Assignment(Employee_ID);
CREATE INDEX idx_assignment_proj ON Assignment(Project_ID);

-- 5.2 Query to identify slow queries (PostgreSQL)
-- SELECT query, calls, total_time, mean_time
-- FROM pg_stat_statements
-- ORDER BY mean_time DESC
-- LIMIT 10;

-- 5.3 Analyze table statistics for query optimizer
-- ANALYZE Employee;
-- ANALYZE Project;
-- ANALYZE Assignment;

-- 5.4 Check table sizes and bloat
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    n_live_tup AS row_count
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 5.5 Monitor active connections
-- SELECT pid, usename, application_name, client_addr, state, query_start
-- FROM pg_stat_activity
-- WHERE state = 'active';

-- 5.6 Optimize a sample query with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT e.Employee_Name, d.Department_Name, p.Project_Name
FROM Employee e
JOIN Department d ON e.Department_ID = d.Department_ID
JOIN Assignment a ON e.Employee_ID = a.Employee_ID
JOIN Project p ON a.Project_ID = p.Project_ID
WHERE p.Status = 'Active';

-- ============================================================
-- TASK 6: DATA INTEGRITY AND CONSISTENCY MANAGEMENT
-- DBA ensures data accuracy through constraints and triggers
-- ============================================================

-- 6.1 Constraints already defined in table creation:
-- - PRIMARY KEY constraints
-- - FOREIGN KEY constraints with referential integrity
-- - CHECK constraints (Salary > 0, Budget >= 0, etc.)
-- - UNIQUE constraints (Email, Department_Name)
-- - NOT NULL constraints

-- 6.2 Create a trigger to maintain data consistency
-- Trigger: Update department employee count when employees are added/removed

CREATE TABLE Department_Stats (
    Department_ID       INT PRIMARY KEY,
    Employee_Count      INT DEFAULT 0,
    Last_Updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Stats_Dept FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID)
);

-- Initialize stats
INSERT INTO Department_Stats (Department_ID, Employee_Count)
SELECT Department_ID, COUNT(*)
FROM Employee
GROUP BY Department_ID;

-- Create trigger function (PostgreSQL)
CREATE OR REPLACE FUNCTION update_dept_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE Department_Stats
        SET Employee_Count = Employee_Count + 1,
            Last_Updated = CURRENT_TIMESTAMP
        WHERE Department_ID = NEW.Department_ID;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE Department_Stats
        SET Employee_Count = Employee_Count - 1,
            Last_Updated = CURRENT_TIMESTAMP
        WHERE Department_ID = OLD.Department_ID;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.Department_ID != NEW.Department_ID THEN
            UPDATE Department_Stats
            SET Employee_Count = Employee_Count - 1,
                Last_Updated = CURRENT_TIMESTAMP
            WHERE Department_ID = OLD.Department_ID;

            UPDATE Department_Stats
            SET Employee_Count = Employee_Count + 1,
                Last_Updated = CURRENT_TIMESTAMP
            WHERE Department_ID = NEW.Department_ID;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trg_employee_dept_stats
AFTER INSERT OR UPDATE OR DELETE ON Employee
FOR EACH ROW EXECUTE FUNCTION update_dept_stats();

-- 6.3 Data validation query
SELECT 'Data Integrity Check' AS Check_Type,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASSED: No orphaned employee records'
        ELSE 'FAILED: Found orphaned employee records'
    END AS Result
FROM Employee e
LEFT JOIN Department d ON e.Department_ID = d.Department_ID
WHERE e.Department_ID IS NOT NULL AND d.Department_ID IS NULL;

-- ============================================================
-- TASK 7: STORAGE AND DATABASE MAINTENANCE
-- DBA manages storage and performs maintenance tasks
-- ============================================================

-- 7.1 Check database size
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size;

-- 7.2 Check tablespace usage
SELECT spcname, pg_size_pretty(pg_tablespace_size(spcname)) AS size
FROM pg_tablespace;

-- 7.3 Vacuum to reclaim storage and update statistics
-- VACUUM ANALYZE Employee;
-- VACUUM ANALYZE Project;
-- VACUUM FULL Employee;  -- Reclaims all space but locks table

-- 7.4 Reindex to improve performance
-- REINDEX TABLE Employee;
-- REINDEX DATABASE OrganizationDB;

-- 7.5 Identify tables needing maintenance
SELECT
    schemaname,
    tablename,
    n_dead_tup,
    n_live_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 100
ORDER BY n_dead_tup DESC;

-- 7.6 Archive old data (example: move old projects to archive table)
CREATE TABLE Project_Archive (
    LIKE Project INCLUDING ALL
);

-- Insert old projects (older than 1 year)
-- INSERT INTO Project_Archive
-- SELECT * FROM Project
-- WHERE End_Date < CURRENT_DATE - INTERVAL '1 year';

-- Delete archived projects from main table
-- DELETE FROM Project
-- WHERE End_Date < CURRENT_DATE - INTERVAL '1 year';

-- ============================================================
-- TASK 8: TROUBLESHOOTING AND DISASTER RECOVERY
-- DBA diagnoses and resolves database issues
-- ============================================================

-- 8.1 Check for blocking queries
-- SELECT blocked_locks.pid AS blocked_pid,
--        blocked_activity.usename AS blocked_user,
--        blocking_locks.pid AS blocking_pid,
--        blocking_activity.usename AS blocking_user,
--        blocked_activity.query AS blocked_query,
--        blocking_activity.query AS blocking_query
-- FROM pg_catalog.pg_locks blocked_locks
-- JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
-- JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
-- JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
-- WHERE NOT blocked_locks.granted;

-- 8.2 Monitor long-running queries
-- SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
-- FROM pg_stat_activity
-- WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
-- AND state != 'idle';

-- 8.3 Check disk space
-- SELECT pg_size_pretty(pg_tablespace_size('pg_default')) AS default_tablespace_size;

-- 8.4 Identify missing indexes
-- SELECT schemaname, tablename, attname, n_distinct, correlation
-- FROM pg_stats
-- WHERE schemaname = 'public'
-- AND n_distinct > 100;

-- 8.5 Disaster recovery plan documentation
-- Step 1: Identify the failure type (hardware, software, data corruption)
-- Step 2: Assess data loss extent
-- Step 3: Restore from latest backup
-- Step 4: Apply transaction logs (WAL) to recover to point of failure
-- Step 5: Verify data integrity
-- Step 6: Bring database online
-- Step 7: Notify users and monitor closely

-- ============================================================
-- TASK 9: USER AND PRIVILEGE MANAGEMENT
-- DBA manages database users and their permissions
-- ============================================================

-- 9.1 List all database users (PostgreSQL)
-- SELECT usename, usesysid, usecreatedb, usesuper
-- FROM pg_user;

-- 9.2 List all roles
-- SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolcanlogin
-- FROM pg_roles;

-- 9.3 Check user privileges on a table
-- SELECT grantee, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE table_name = 'Employee';

-- 9.4 Modify user password
-- ALTER USER hr_manager WITH PASSWORD 'new_secure_password';

-- 9.5 Lock/unlock user account
-- ALTER USER hr_manager CONNECTION LIMIT 0;  -- Lock (no connections allowed)
-- ALTER USER hr_manager CONNECTION LIMIT -1; -- Unlock

-- 9.6 Create audit log for privilege changes
CREATE TABLE Privilege_Audit (
    Audit_ID        SERIAL PRIMARY KEY,
    Event_Type      VARCHAR(20) NOT NULL,
    User_Name       VARCHAR(50) NOT NULL,
    Table_Name      VARCHAR(50),
    Privilege       VARCHAR(50),
    Changed_By      VARCHAR(50) DEFAULT current_user,
    Changed_At      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TASK 10: ENSURE DATABASE AVAILABILITY, RELIABILITY, SECURITY
-- DBA implements strategies for 24/7 operation
-- ============================================================

-- 10.1 Monitor database uptime
SELECT pg_postmaster_start_time() AS server_start_time,
       now() - pg_postmaster_start_time() AS uptime;

-- 10.2 Check replication status (for high availability)
-- SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn
-- FROM pg_stat_replication;

-- 10.3 Set up connection pooling (pgbouncer configuration)
-- [databases]
-- OrganizationDB = host=127.0.0.1 port=5432 dbname=OrganizationDB
-- [pgbouncer]
-- listen_port = 6432
-- listen_addr = *
-- max_client_conn = 1000
-- default_pool_size = 20

-- 10.4 Implement row-level security (PostgreSQL)
-- CREATE POLICY employee_department_policy ON Employee
-- FOR SELECT
-- USING (Department_ID = current_setting('app.current_dept_id')::int);

-- 10.5 Create monitoring dashboard queries
-- Query 1: Database health summary
SELECT 'Database Health Check' AS Report_Type,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
    pg_size_pretty(pg_database_size(current_database())) AS db_size;

-- Query 2: Table statistics summary
SELECT 'Table Statistics' AS Report_Type,
    COUNT(*) AS total_tables,
    SUM(n_live_tup) AS total_rows,
    pg_size_pretty(SUM(pg_total_relation_size(schemaname||'.'||tablename))::bigint) AS total_size
FROM pg_stat_user_tables;

-- Query 3: Security audit - users with excessive privileges
-- SELECT r.rolname, r.rolsuper, r.rolcreaterole
-- FROM pg_roles r
-- WHERE r.rolsuper = true OR r.rolcreaterole = true;

-- ============================================================
-- COMPREHENSIVE QUERIES TO DISPLAY ALL DATA
-- ============================================================

-- Query 1: Department overview with employee count
SELECT
    d.Department_ID,
    d.Department_Name,
    d.Location,
    d.Budget,
    ds.Employee_Count,
    ds.Last_Updated
FROM Department d
LEFT JOIN Department_Stats ds ON d.Department_ID = ds.Department_ID
ORDER BY d.Department_ID;

-- Query 2: Employee details with department and project assignments
SELECT
    e.Employee_ID,
    e.Employee_Name,
    e.Email,
    e.Hire_Date,
    e.Salary,
    d.Department_Name,
    p.Project_Name,
    a.Role,
    a.Hours_Per_Week
FROM Employee e
LEFT JOIN Department d ON e.Department_ID = d.Department_ID
LEFT JOIN Assignment a ON e.Employee_ID = a.Employee_ID
LEFT JOIN Project p ON a.Project_ID = p.Project_ID
ORDER BY e.Employee_ID;

-- Query 3: Project summary with team size and budget utilization
SELECT
    p.Project_ID,
    p.Project_Name,
    p.Status,
    p.Budget,
    p.Start_Date,
    p.End_Date,
    d.Department_Name,
    COUNT(a.Employee_ID) AS Team_Size,
    SUM(a.Hours_Per_Week) AS Total_Hours_Per_Week
FROM Project p
JOIN Department d ON p.Department_ID = d.Department_ID
LEFT JOIN Assignment a ON p.Project_ID = a.Project_ID
GROUP BY p.Project_ID, p.Project_Name, p.Status, p.Budget,
         p.Start_Date, p.End_Date, d.Department_Name
ORDER BY p.Project_ID;

-- Query 4: Department-wise budget and salary analysis
SELECT
    d.Department_Name,
    d.Budget AS Dept_Budget,
    COUNT(e.Employee_ID) AS Employee_Count,
    COALESCE(SUM(e.Salary), 0) AS Total_Salary,
    d.Budget - COALESCE(SUM(e.Salary), 0) AS Remaining_Budget
FROM Department d
LEFT JOIN Employee e ON d.Department_ID = e.Department_ID
GROUP BY d.Department_ID, d.Department_Name, d.Budget
ORDER BY d.Department_ID;

-- Query 5: Active projects with assigned employees
SELECT
    p.Project_Name,
    p.Status,
    STRING_AGG(e.Employee_Name || ' (' || a.Role || ')', ', ') AS Team_Members
FROM Project p
LEFT JOIN Assignment a ON p.Project_ID = a.Project_ID
LEFT JOIN Employee e ON a.Employee_ID = e.Employee_ID
WHERE p.Status = 'Active'
GROUP BY p.Project_ID, p.Project_Name, p.Status
ORDER BY p.Project_Name;

-- ============================================================
-- CLEANUP (uncomment to drop all objects)
-- ============================================================
-- DROP TRIGGER IF EXISTS trg_employee_dept_stats ON Employee;
-- DROP FUNCTION IF EXISTS update_dept_stats();
-- DROP TABLE IF EXISTS Privilege_Audit;
-- DROP TABLE IF EXISTS Department_Stats;
-- DROP TABLE IF EXISTS Project_Archive;
-- DROP TABLE IF EXISTS Assignment;
-- DROP TABLE IF EXISTS Project;
-- DROP TABLE IF EXISTS Employee;
-- DROP TABLE IF EXISTS Department;
-- DROP DATABASE IF EXISTS OrganizationDB;
