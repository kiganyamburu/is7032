-- IS7032 Assignment 4 - PostgreSQL SQL Script
-- Derived from the logical model shown in IS7032_A4.doc screenshots.
--
-- Assumptions noted:
-- 1) L2 MANAGER is a subtype of L1 EMPLOYEE (1:1 via mng_emp_id = emp_id).
-- 2) L5 EXTERNAL and L6 INTERNAL are subtypes of L4 PROJECT (PK=FK to PROJECT).
-- 3) L7 ASSIGNMENT links EMPLOYEE and INTERNAL projects (composite PK).
-- 4) VENDOR natural key is ven_name (as shown in model).
-- 5) internal_project.int_rating uses one-character code and is constrained to A/B/C/D/F.

DROP TABLE IF EXISTS assignment CASCADE;
DROP TABLE IF EXISTS external_project CASCADE;
DROP TABLE IF EXISTS internal_project CASCADE;
DROP TABLE IF EXISTS manager CASCADE;
DROP TABLE IF EXISTS vendor CASCADE;
DROP TABLE IF EXISTS project CASCADE;
DROP TABLE IF EXISTS employee CASCADE;

CREATE TABLE employee (
    emp_id            NUMERIC(9,0) PRIMARY KEY,
    emp_first         VARCHAR(20) NOT NULL,
    emp_middle        VARCHAR(20),
    emp_last          VARCHAR(20) NOT NULL,
    emp_gender        CHAR(1) NOT NULL,
    emp_salary        NUMERIC(6,0),
    CONSTRAINT chk_employee_gender
        CHECK (emp_gender IN ('M', 'F', 'O'))
);

CREATE TABLE manager (
    mng_emp_id        NUMERIC(9,0) PRIMARY KEY,
    mng_bonus         NUMERIC(6,0) NOT NULL,
    CONSTRAINT fk_manager_employee
        FOREIGN KEY (mng_emp_id)
        REFERENCES employee(emp_id)
        ON DELETE CASCADE
);

CREATE TABLE vendor (
    ven_name          VARCHAR(60) PRIMARY KEY,
    ven_street        VARCHAR(50),
    ven_city          VARCHAR(20),
    ven_state         CHAR(2),
    ven_zip           CHAR(5),
    ven_first         VARCHAR(20) NOT NULL,
    ven_middle        VARCHAR(20),
    ven_last          VARCHAR(20) NOT NULL
);

CREATE TABLE project (
    prj_num           NUMERIC(9,0) PRIMARY KEY,
    prj_desc          VARCHAR(120) NOT NULL,
    prj_startdt       DATE,
    prj_budget        NUMERIC(8,2) NOT NULL,
    prj_actcst        NUMERIC(8,2)
);

CREATE TABLE external_project (
    ext_prj_num       NUMERIC(9,0) PRIMARY KEY,
    ext_contcost      NUMERIC(8,2),
    ext_ven_name      VARCHAR(60),
    CONSTRAINT fk_external_project_project
        FOREIGN KEY (ext_prj_num)
        REFERENCES project(prj_num)
        ON DELETE CASCADE,
    CONSTRAINT fk_external_project_vendor
        FOREIGN KEY (ext_ven_name)
        REFERENCES vendor(ven_name)
        ON DELETE SET NULL
);

CREATE TABLE internal_project (
    int_prj_num       NUMERIC(9,0) PRIMARY KEY,
    int_rating        CHAR(1),
    int_mng_emp_id    NUMERIC(9,0) NOT NULL,
    CONSTRAINT fk_internal_project_project
        FOREIGN KEY (int_prj_num)
        REFERENCES project(prj_num)
        ON DELETE CASCADE,
    CONSTRAINT fk_internal_project_manager
        FOREIGN KEY (int_mng_emp_id)
        REFERENCES manager(mng_emp_id),
    CONSTRAINT chk_internal_rating
        CHECK (int_rating IN ('A','B','C','D','F'))
);

CREATE TABLE assignment (
    asg_int_prj_num   NUMERIC(9,0) NOT NULL,
    asg_emp_id        NUMERIC(9,0) NOT NULL,
    asg_hours         NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_assignment
        PRIMARY KEY (asg_int_prj_num, asg_emp_id),
    CONSTRAINT fk_assignment_internal_project
        FOREIGN KEY (asg_int_prj_num)
        REFERENCES internal_project(int_prj_num)
        ON DELETE CASCADE,
    CONSTRAINT fk_assignment_employee
        FOREIGN KEY (asg_emp_id)
        REFERENCES employee(emp_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_assignment_hours
        CHECK (asg_hours > 1)
);

-- Section 4 rule implementation:
-- Ensure a manager is assigned to the internal project he/she manages.
-- This trigger auto-inserts a row into ASSIGNMENT for (int_prj_num, int_mng_emp_id)
-- whenever an internal project is inserted/updated.

CREATE OR REPLACE FUNCTION fn_assign_manager_to_internal_project()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO assignment (asg_int_prj_num, asg_emp_id, asg_hours)
    VALUES (NEW.int_prj_num, NEW.int_mng_emp_id, 2)
    ON CONFLICT (asg_int_prj_num, asg_emp_id)
    DO NOTHING;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_assign_manager_to_internal_project ON internal_project;

CREATE TRIGGER trg_assign_manager_to_internal_project
AFTER INSERT OR UPDATE OF int_mng_emp_id
ON internal_project
FOR EACH ROW
EXECUTE FUNCTION fn_assign_manager_to_internal_project();

-- ---------------------------------------------------------------------
-- Section 3 sample data (5+ records into one table + supporting rows)
-- ---------------------------------------------------------------------

INSERT INTO employee (emp_id, emp_first, emp_middle, emp_last, emp_gender, emp_salary) VALUES
(100000001, 'John',  'A', 'Miller', 'M', 65000),
(100000002, 'Mary',  'B', 'Smith',  'F', 70000),
(100000003, 'Alex',  NULL, 'Taylor', 'O', 62000),
(100000004, 'Priya', 'C', 'Shah',   'F', 71000),
(100000005, 'David', NULL, 'Brown', 'M', 68000);

INSERT INTO manager (mng_emp_id, mng_bonus) VALUES
(100000002, 8000),
(100000004, 9000);

INSERT INTO vendor (ven_name, ven_street, ven_city, ven_state, ven_zip, ven_first, ven_middle, ven_last) VALUES
('CoreBuild LLC', '12 Oak St', 'Albany', 'NY', '12201', 'Nina', NULL, 'Reed');

INSERT INTO project (prj_num, prj_desc, prj_startdt, prj_budget, prj_actcst) VALUES
(200000001, 'Payroll Upgrade', '2026-02-01', 120000.00, 45000.00),
(200000002, 'ERP Rollout',     '2026-03-01', 250000.00, 90000.00),
(200000003, 'Vendor Portal',   '2026-01-15',  80000.00, 30000.00);

INSERT INTO internal_project (int_prj_num, int_rating, int_mng_emp_id) VALUES
(200000001, 'A', 100000002),
(200000002, 'B', 100000004);

INSERT INTO external_project (ext_prj_num, ext_contcost, ext_ven_name) VALUES
(200000003, 50000.00, 'CoreBuild LLC');

-- Add extra assignment rows (manager rows are auto-added by trigger)
INSERT INTO assignment (asg_int_prj_num, asg_emp_id, asg_hours) VALUES
(200000001, 100000001, 6.5),
(200000001, 100000003, 4.0),
(200000002, 100000005, 3.0)
ON CONFLICT DO NOTHING;

-- For your Section 3 screenshot, run:
SELECT *
FROM assignment
ORDER BY asg_int_prj_num, asg_emp_id;

-- Optional verification query for Section 4 business rule:
-- Should return 0 rows when rule is satisfied.
SELECT ip.int_prj_num, ip.int_mng_emp_id
FROM internal_project ip
LEFT JOIN assignment a
    ON a.asg_int_prj_num = ip.int_prj_num
   AND a.asg_emp_id = ip.int_mng_emp_id
WHERE a.asg_emp_id IS NULL;
