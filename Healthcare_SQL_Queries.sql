-- ============================================================
-- Healthcare SQL Project (PostgreSQL)
-- Dataset: healthcare_dataset_1000.csv  |  Database: healthcare_db
-- Note: the staging_healthcare table used in A2 has the same columns as the CSV.
-- ============================================================


-- ============================================================
-- SECTION A: Database, Tables and Basic SQL
-- ============================================================

-- A1. Create a PostgreSQL database for the project.
CREATE DATABASE healthcare_db;


-- A2. Create the required table(s) with suitable data types.
-- Create the four tables
CREATE TABLE hospitals (
    hospital_id   SERIAL,
    hospital_name VARCHAR(60) NOT NULL,
    CONSTRAINT pk_hospitals PRIMARY KEY (hospital_id),
    CONSTRAINT uq_hospital_name UNIQUE (hospital_name)
);

CREATE TABLE doctors (
    doctor_id   SERIAL,
    doctor_name VARCHAR(60) NOT NULL,
    CONSTRAINT pk_doctors PRIMARY KEY (doctor_id),
    CONSTRAINT uq_doctor_name UNIQUE (doctor_name)
);

CREATE TABLE patients (
    patient_id        INT,
    patient_name      VARCHAR(80) NOT NULL,
    age               INT NOT NULL,
    gender            VARCHAR(10) NOT NULL,
    city              VARCHAR(50),
    blood_group       VARCHAR(5),
    medical_condition VARCHAR(50),
    systolic_bp       INT,
    diastolic_bp      INT,
    heart_rate        INT,
    oxygen_level      NUMERIC(4,1),
    temperature       NUMERIC(4,1),
    weight_kg         NUMERIC(5,1),
    height_cm         NUMERIC(5,1),
    bmi               NUMERIC(4,1),
    admission_type    VARCHAR(20),
    admission_date    DATE NOT NULL,
    discharge_date    DATE,
    length_of_stay    INT,
    doctor_id         INT,
    hospital_id       INT,
    insurance_type    VARCHAR(20),
    treatment_cost    INT,
    medication        VARCHAR(50),
    diabetic          VARCHAR(3),
    smoker            VARCHAR(3),
    readmission       VARCHAR(3),
    outcome           VARCHAR(30),
    CONSTRAINT pk_patients PRIMARY KEY (patient_id),
    CONSTRAINT fk_patients_doctor FOREIGN KEY (doctor_id)
        REFERENCES doctors (doctor_id),
    CONSTRAINT fk_patients_hospital FOREIGN KEY (hospital_id)
        REFERENCES hospitals (hospital_id),
    CONSTRAINT chk_patients_age CHECK (age BETWEEN 0 AND 120),
    CONSTRAINT chk_patients_gender CHECK (gender IN ('Male','Female')),
    CONSTRAINT chk_patients_los CHECK (length_of_stay >= 0),
    CONSTRAINT chk_patients_cost CHECK (treatment_cost >= 0),
    CONSTRAINT chk_patients_dates CHECK (discharge_date >= admission_date)
);

CREATE TABLE readmission_log (
    record_id   SERIAL,
    patient_id  INT NOT NULL,
    recorded_on DATE,
    CONSTRAINT pk_readmission_log PRIMARY KEY (record_id),
    CONSTRAINT fk_readmission_patient FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
);

-- Load the dataset into the tables
-- Load the CSV into the tables (staging table has the same columns as the CSV)
COPY staging_healthcare FROM 'healthcare_dataset_1000.csv' CSV HEADER;

INSERT INTO hospitals (hospital_name) SELECT DISTINCT hospital FROM staging_healthcare ORDER BY 1;
INSERT INTO doctors (doctor_name)     SELECT DISTINCT doctor   FROM staging_healthcare ORDER BY 1;

INSERT INTO patients
SELECT s.patient_id, s.patient_name, s.age, s.gender, s.city, s.blood_group,
       s.medical_condition, s.systolic_bp, s.diastolic_bp, s.heart_rate, s.oxygen_level,
       s.temperature, s.weight_kg, s.height_cm, s.bmi, s.admission_type, s.admission_date,
       s.discharge_date, s.length_of_stay, d.doctor_id, h.hospital_id, s.insurance_type,
       s.treatment_cost, s.medication, s.diabetic, s.smoker, s.readmission, s.outcome
FROM staging_healthcare s
JOIN doctors   d ON d.doctor_name   = s.doctor
JOIN hospitals h ON h.hospital_name = s.hospital;

INSERT INTO readmission_log (patient_id, recorded_on)
SELECT patient_id, discharge_date FROM patients WHERE readmission = 'Yes';


-- A3. Identify and create primary key(s).
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND constraint_type = 'PRIMARY KEY'
ORDER BY table_name;


-- A4. Identify relationships and create foreign key(s) where applicable.
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND constraint_type = 'FOREIGN KEY'
ORDER BY table_name, constraint_name;


-- A5. Add suitable NOT NULL, UNIQUE and CHECK constraints.
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND (constraint_type = 'UNIQUE'
       OR (constraint_type = 'CHECK' AND constraint_name LIKE 'chk_%'))
ORDER BY constraint_type, constraint_name;


-- A6. Insert at least 10 practice records manually where applicable.

INSERT INTO patients (patient_id, patient_name, age, gender, city, blood_group,
    medical_condition, admission_type, admission_date, discharge_date, length_of_stay,
    doctor_id, hospital_id, insurance_type, treatment_cost, medication,
    diabetic, smoker, readmission, outcome)
VALUES
(1001,'Test Patient 01',34,'Female','Pune','O+','Flu','Routine','2026-05-20',
    '2026-05-22',2,1,1,'Private',52000,'Paracetamol','No','No','No','Improved'),
(1002,'Test Patient 02',46,'Male','Mumbai','A+','Asthma','Emergency','2026-05-21',
    '2026-05-25',4,2,2,'Government',61000,'Salbutamol','No','Yes','No','Improved'),
(1003,'Test Patient 03',58,'Female','Nashik','B+','Diabetes','Referral','2026-05-22',
    '2026-05-29',7,3,3,'Self Pay',73000,'Metformin','Yes','No','No','Under Treatment'),
(1004,'Test Patient 04',29,'Male','Delhi','AB+','Migraine','Routine','2026-05-23',
    '2026-05-24',1,4,4,'Private',48000,'Ibuprofen','No','No','No','Recovered'),
(1005,'Test Patient 05',63,'Female','Nagpur','O-','Hypertension','Emergency','2026-05-24',
    '2026-06-01',8,5,5,'Government',88000,'Amlodipine','No','Yes','No','Under Treatment'),
(1006,'Test Patient 06',41,'Male','Hyderabad','B-','Arthritis','Routine','2026-05-25',
    '2026-05-28',3,1,2,'Private',56000,'Ibuprofen','No','No','No','Improved'),
(1007,'Test Patient 07',52,'Female','Bengaluru','A-','Heart Disease','Referral','2026-05-26',
    '2026-06-03',8,2,3,'Government',94000,'Atorvastatin','Yes','No','No','Referred'),
(1008,'Test Patient 08',37,'Male','Pune','AB-','Flu','Routine','2026-05-27',
    '2026-05-29',2,3,4,'Self Pay',45000,'Paracetamol','No','Yes','No','Recovered'),
(1009,'Test Patient 09',68,'Female','Mumbai','O+','Diabetes','Emergency','2026-05-28',
    '2026-06-05',8,4,5,'Private',79000,NULL,'Yes','No','No','Under Treatment'),
(1010,'Test Patient 10',24,'Male','Nashik','A+','Asthma','Routine','2026-05-29',
    '2026-05-31',2,5,1,'Government',50000,NULL,'No','No','No','Improved');


-- A7. Display all records from the main table.
SELECT * FROM patients;


-- A8. Display only selected columns required for analysis.
SELECT patient_id, patient_name, age, gender, city,
       medical_condition, treatment_cost
FROM patients;


-- ============================================================
-- SECTION B: SELECT, WHERE, Operators and Sorting
-- ============================================================

-- B1. Filter records using WHERE for one condition.
SELECT patient_id, patient_name, age, city, medical_condition
FROM patients
WHERE medical_condition = 'Diabetes';


-- B2. Filter using AND and OR.
SELECT patient_id, patient_name, age, city, treatment_cost
FROM patients
WHERE (city = 'Pune' OR city = 'Mumbai')
  AND age >= 60;


-- B3. Use NOT to reverse a condition.
SELECT patient_id, patient_name, admission_type, treatment_cost
FROM patients
WHERE NOT admission_type = 'Emergency';


-- B4. Use IN and NOT IN.
-- IN
SELECT patient_id, patient_name, medical_condition, age
FROM patients
WHERE medical_condition IN ('Heart Disease', 'Hypertension', 'Diabetes');

-- NOT IN
SELECT patient_id, patient_name, city
FROM patients
WHERE city NOT IN ('Mumbai', 'Delhi', 'Pune');


-- B5. Use BETWEEN and NOT BETWEEN.
-- BETWEEN
SELECT patient_id, patient_name, age, medical_condition
FROM patients
WHERE age BETWEEN 30 AND 45;

-- NOT BETWEEN
SELECT patient_id, patient_name, treatment_cost
FROM patients
WHERE treatment_cost NOT BETWEEN 20000 AND 130000;


-- B6. Use LIKE for text-pattern searching.
SELECT patient_id, patient_name, city
FROM patients
WHERE patient_name LIKE 'S%'
  AND city LIKE 'N%';


-- B7. Use IS NULL and IS NOT NULL.
-- IS NULL
SELECT patient_id, patient_name, medication
FROM patients
WHERE medication IS NULL;

-- IS NOT NULL
SELECT patient_id, patient_name, medication
FROM patients
WHERE medication IS NOT NULL;


-- B8. Use DISTINCT to find unique categories.
SELECT DISTINCT medical_condition
FROM patients
ORDER BY medical_condition;


-- B9. Sort results using ORDER BY ASC and DESC.
-- Descending
SELECT patient_id, patient_name, treatment_cost
FROM patients
ORDER BY treatment_cost DESC;

-- Ascending
SELECT patient_id, patient_name, age
FROM patients
ORDER BY age ASC, patient_name ASC;


-- B10. Return top records using LIMIT and, where useful, OFFSET.
-- Top 5
SELECT patient_id, patient_name, treatment_cost
FROM patients
ORDER BY treatment_cost DESC
LIMIT 5;

-- Next 5 (rank 6 to 10)
SELECT patient_id, patient_name, treatment_cost
FROM patients
ORDER BY treatment_cost DESC
LIMIT 5 OFFSET 5;


-- ============================================================
-- SECTION C: ALTER, UPDATE, DELETE and CASE
-- ============================================================

-- C1. Add a useful column using ALTER TABLE.
ALTER TABLE patients
ADD COLUMN cost_category VARCHAR(10);

-- Check the new column
SELECT patient_id, patient_name, treatment_cost, cost_category
FROM patients
ORDER BY patient_id
LIMIT 5;


-- C2. Update selected records using UPDATE.
UPDATE patients
SET outcome = 'Recovered'
WHERE patient_id BETWEEN 1001 AND 1005;

-- Check the updated rows
SELECT patient_id, patient_name, outcome
FROM patients
WHERE patient_id BETWEEN 1001 AND 1005;


-- C3. Use CASE WHEN inside UPDATE for multiple conditions.
UPDATE patients
SET cost_category = CASE
        WHEN treatment_cost < 40000  THEN 'Low'
        WHEN treatment_cost < 100000 THEN 'Medium'
        ELSE 'High'
    END;

-- Check the result
SELECT cost_category, COUNT(*) AS patients
FROM patients
GROUP BY cost_category
ORDER BY patients DESC;


-- C4. Delete selected test records using DELETE with WHERE.
DELETE FROM patients
WHERE patient_id > 1000;

-- Check the remaining rows
SELECT COUNT(*) AS total_patients
FROM patients;


-- C5. Explain DELETE vs TRUNCATE vs DROP.

-- ============================================================
-- SECTION D: Aggregate Functions, GROUP BY and HAVING
-- ============================================================

-- D1. Use COUNT, SUM, AVG, MIN and MAX.
SELECT COUNT(*)                     AS total_patients,
       SUM(treatment_cost)          AS total_cost,
       ROUND(AVG(treatment_cost),2) AS avg_cost,
       MIN(treatment_cost)          AS min_cost,
       MAX(treatment_cost)          AS max_cost
FROM patients;


-- D2. Calculate totals by category using GROUP BY.
SELECT medical_condition, SUM(treatment_cost) AS total_cost
FROM patients
GROUP BY medical_condition
ORDER BY total_cost DESC;


-- D3. Calculate averages by category.
SELECT admission_type,
       ROUND(AVG(length_of_stay),2) AS avg_stay_days,
       ROUND(AVG(treatment_cost),2) AS avg_cost
FROM patients
GROUP BY admission_type
ORDER BY avg_cost DESC;

-- D4. Calculate counts by category.
SELECT outcome, COUNT(*) AS patients
FROM patients
GROUP BY outcome
ORDER BY patients DESC;


-- D5. Calculate totals by city/region/department/category.
SELECT city, COUNT(*) AS patients, SUM(treatment_cost) AS total_cost
FROM patients
GROUP BY city
ORDER BY total_cost DESC;


-- D6. Use HAVING with COUNT or SUM.
-- HAVING with COUNT
SELECT medical_condition, COUNT(*) AS patients
FROM patients
GROUP BY medical_condition
HAVING COUNT(*) > 130
ORDER BY patients DESC;

-- HAVING with SUM
SELECT city, SUM(treatment_cost) AS total_cost
FROM patients
GROUP BY city
HAVING SUM(treatment_cost) > 9500000
ORDER BY total_cost DESC;


-- D7. Find groups above a selected threshold.
SELECT insurance_type, ROUND(AVG(treatment_cost),2) AS avg_cost
FROM patients
GROUP BY insurance_type
HAVING AVG(treatment_cost) > 76500
ORDER BY avg_cost DESC;


-- D8. Find the group with the highest aggregate value.
SELECT city, SUM(treatment_cost) AS total_cost
FROM patients
GROUP BY city
ORDER BY total_cost DESC
LIMIT 1;


-- ============================================================
-- SECTION E: NULL, DISTINCT, CASE and Data Cleaning
-- ============================================================

-- E1. Create a CASE classification with at least 3 categories.
SELECT CASE
           WHEN age < 36 THEN 'Young Adult (18-35)'
           WHEN age < 60 THEN 'Middle Aged (36-59)'
           ELSE 'Senior (60+)'
       END AS age_group,
       COUNT(*) AS patients
FROM patients
GROUP BY age_group
ORDER BY patients DESC;


-- E2. Use COALESCE to handle NULL values.
SELECT patient_id, patient_name, medication,
       COALESCE(NULLIF(medication, 'None'), 'Not Prescribed') AS medication_clean
FROM patients
WHERE medication = 'None'
ORDER BY patient_id;


-- E3. Identify blank values if present.
SELECT SUM(CASE WHEN patient_name IS NULL OR TRIM(patient_name) = '' THEN 1 ELSE 0 END) AS blank_names,
       SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END)                 AS blank_city,
       SUM(CASE WHEN medication IS NULL OR TRIM(medication) = ''
                 OR medication = 'None' THEN 1 ELSE 0 END)                             AS no_medication
FROM patients;


-- E4. Find duplicates using GROUP BY and HAVING COUNT(*) > 1.
-- Repeated names
SELECT patient_name, COUNT(*) AS occurrences
FROM patients
GROUP BY patient_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Real duplicates (same name, age, city and admission date)
SELECT patient_name, age, city, admission_date, COUNT(*) AS occurrences
FROM patients
GROUP BY patient_name, age, city, admission_date
HAVING COUNT(*) > 1;


-- E5. Create a cleaned output with standardized labels.
SELECT patient_id,
       UPPER(TRIM(patient_name))                     AS patient_name,
       UPPER(city)                                   AS city,
       CASE WHEN diabetic = 'Yes' THEN 'Diabetic' ELSE 'Non-Diabetic' END AS diabetes_status,
       CASE WHEN smoker = 'Yes' THEN 'Smoker' ELSE 'Non-Smoker' END       AS smoking_status,
       COALESCE(NULLIF(medication, 'None'), 'Not Prescribed')             AS medication
FROM patients
ORDER BY patient_id;


-- ============================================================
-- SECTION F: JOIN Practice
-- ============================================================

-- F1. INNER JOIN two related tables.
SELECT p.patient_id, p.patient_name, d.doctor_name, p.medical_condition
FROM patients p
INNER JOIN doctors d ON p.doctor_id = d.doctor_id
ORDER BY p.patient_id;


-- F2. LEFT JOIN two related tables.
SELECT p.patient_id, p.patient_name, p.readmission, r.record_id, r.recorded_on
FROM patients p
LEFT JOIN readmission_log r ON p.patient_id = r.patient_id
ORDER BY p.patient_id;


-- F3. Find parent records with no child record.
SELECT p.patient_id, p.patient_name, p.medical_condition
FROM patients p
LEFT JOIN readmission_log r ON p.patient_id = r.patient_id
WHERE r.record_id IS NULL
ORDER BY p.patient_id;


-- F4. JOIN three tables and create a summary.
SELECT h.hospital_name, d.doctor_name,
       COUNT(*)            AS patients,
       SUM(p.treatment_cost) AS total_cost
FROM patients p
JOIN doctors   d ON p.doctor_id   = d.doctor_id
JOIN hospitals h ON p.hospital_id = h.hospital_id
GROUP BY h.hospital_name, d.doctor_name
ORDER BY total_cost DESC;


-- F5. Use JOIN + GROUP BY for category/entity totals.
SELECT h.hospital_name,
       COUNT(p.patient_id)             AS patients,
       SUM(p.treatment_cost)           AS total_cost,
       ROUND(AVG(p.treatment_cost),2)  AS avg_cost
FROM hospitals h
JOIN patients p ON p.hospital_id = h.hospital_id
GROUP BY h.hospital_name
ORDER BY total_cost DESC;


-- F6. Compare two related tables and find unmatched records.
SELECT 'Patients without readmission record' AS unmatched_type, COUNT(*) AS records
FROM patients p
LEFT JOIN readmission_log r ON p.patient_id = r.patient_id
WHERE r.record_id IS NULL
UNION ALL
SELECT 'Readmission records without patient', COUNT(*)
FROM readmission_log r
LEFT JOIN patients p ON p.patient_id = r.patient_id
WHERE p.patient_id IS NULL;


-- ============================================================
-- SECTION G: UNION / UNION ALL
-- ============================================================

-- G1. Write a UNION between two compatible result sets.
SELECT city FROM patients WHERE diabetic = 'Yes'
UNION
SELECT city FROM patients WHERE smoker = 'Yes'
ORDER BY city;


-- G2. Write UNION ALL and explain the difference.
SELECT 'UNION' AS method, COUNT(*) AS rows_returned
FROM (SELECT city FROM patients WHERE diabetic = 'Yes'
      UNION
      SELECT city FROM patients WHERE smoker = 'Yes') t
UNION ALL
SELECT 'UNION ALL', COUNT(*)
FROM (SELECT city FROM patients WHERE diabetic = 'Yes'
      UNION ALL
      SELECT city FROM patients WHERE smoker = 'Yes') t;


-- G3. Combine two business categories into one result.
SELECT patient_id, patient_name, treatment_cost, 'Emergency admission' AS category
FROM patients
WHERE admission_type = 'Emergency' AND treatment_cost > 148000
UNION ALL
SELECT patient_id, patient_name, treatment_cost, 'Private insurance'
FROM patients
WHERE insurance_type = 'Private' AND treatment_cost > 148000
ORDER BY treatment_cost DESC;


-- ============================================================
-- SECTION H: Subqueries
-- ============================================================

-- H1. Find records above the overall average using a scalar subquery.
SELECT patient_id, patient_name, treatment_cost
FROM patients
WHERE treatment_cost > (SELECT AVG(treatment_cost) FROM patients)
ORDER BY treatment_cost DESC;


-- H2. Find the maximum and minimum value using subqueries.
SELECT patient_id, patient_name, treatment_cost
FROM patients
WHERE treatment_cost = (SELECT MAX(treatment_cost) FROM patients)
   OR treatment_cost = (SELECT MIN(treatment_cost) FROM patients);


-- H3. Use IN with a multi-row subquery.
SELECT patient_id, patient_name, medical_condition, doctor_id
FROM patients
WHERE doctor_id IN (SELECT doctor_id
                    FROM doctors
                    WHERE doctor_name IN ('Dr. Sharma', 'Dr. Khan'))
ORDER BY patient_id;


-- H4. Use NOT IN with a multi-row subquery.
SELECT patient_id, patient_name, medical_condition
FROM patients
WHERE patient_id NOT IN (SELECT patient_id FROM readmission_log)
ORDER BY patient_id;


-- H5. Compare each entity with its category/group average using a correlated subquery.
SELECT p.patient_id, p.patient_name, p.medical_condition, p.treatment_cost
FROM patients p
WHERE p.treatment_cost > (SELECT AVG(p2.treatment_cost)
                          FROM patients p2
                          WHERE p2.medical_condition = p.medical_condition)
ORDER BY p.patient_id;


-- ============================================================
-- SECTION I: EXISTS / NOT EXISTS
-- ============================================================

-- I1. Use EXISTS to find entities having related records.
SELECT d.doctor_id, d.doctor_name
FROM doctors d
WHERE EXISTS (SELECT 1 FROM patients p WHERE p.doctor_id = d.doctor_id);


-- I2. Use NOT EXISTS to find entities without related records.
SELECT p.patient_id, p.patient_name, p.medical_condition
FROM patients p
WHERE NOT EXISTS (SELECT 1 FROM readmission_log r WHERE r.patient_id = p.patient_id)
ORDER BY p.patient_id;


-- I3. Use a correlated subquery to find the maximum value within each group.
SELECT p.medical_condition, p.patient_id, p.patient_name, p.treatment_cost
FROM patients p
WHERE p.treatment_cost = (SELECT MAX(p2.treatment_cost)
                          FROM patients p2
                          WHERE p2.medical_condition = p.medical_condition)
ORDER BY p.medical_condition;


-- I4. Explain IN vs EXISTS using your dataset.
SELECT
  (SELECT COUNT(*) FROM patients
   WHERE patient_id IN (SELECT patient_id FROM readmission_log)) AS count_using_in,
  (SELECT COUNT(*) FROM patients p
   WHERE EXISTS (SELECT 1 FROM readmission_log r
                 WHERE r.patient_id = p.patient_id))            AS count_using_exists;


-- ============================================================
-- SECTION J: CTE Practice
-- ============================================================

-- J1. Create a basic CTE and query it.
WITH high_cost AS (
    SELECT * FROM patients WHERE treatment_cost > 100000
)
SELECT patient_id, patient_name, medical_condition, treatment_cost
FROM high_cost
ORDER BY treatment_cost DESC;


-- J2. Create a CTE with GROUP BY.
WITH condition_summary AS (
    SELECT medical_condition,
           COUNT(*)            AS patients,
           SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY medical_condition
)
SELECT * FROM condition_summary
ORDER BY total_cost DESC;


-- J3. Create two CTEs and JOIN them.
WITH cond_avg AS (
    SELECT medical_condition, ROUND(AVG(treatment_cost),2) AS avg_cost
    FROM patients GROUP BY medical_condition
),
emergency_cnt AS (
    SELECT medical_condition, COUNT(*) AS emergency_cases
    FROM patients WHERE admission_type = 'Emergency'
    GROUP BY medical_condition
)
SELECT a.medical_condition, a.avg_cost, e.emergency_cases
FROM cond_avg a
JOIN emergency_cnt e ON a.medical_condition = e.medical_condition
ORDER BY a.avg_cost DESC;


-- J4. Create three CTEs for three separate metrics and combine them.
WITH city_patients AS (
    SELECT city, COUNT(*) AS patients FROM patients GROUP BY city
),
city_cost AS (
    SELECT city, SUM(treatment_cost) AS total_cost FROM patients GROUP BY city
),
city_stay AS (
    SELECT city, ROUND(AVG(length_of_stay),2) AS avg_stay FROM patients GROUP BY city
)
SELECT p.city, p.patients, c.total_cost, s.avg_stay
FROM city_patients p
JOIN city_cost c ON p.city = c.city
JOIN city_stay s ON p.city = s.city
ORDER BY c.total_cost DESC;


-- J5. Create a CTE for entity totals and filter high-value entities.
WITH doctor_totals AS (
    SELECT doctor_id, COUNT(*) AS patients, SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY doctor_id
)
SELECT d.doctor_name, t.patients, t.total_cost
FROM doctor_totals t
JOIN doctors d ON d.doctor_id = t.doctor_id
WHERE t.total_cost > (SELECT AVG(total_cost) FROM doctor_totals)
ORDER BY t.total_cost DESC;


-- J6. Create a monthly/category summary using a CTE.
WITH monthly AS (
    SELECT TO_CHAR(admission_date, 'YYYY-MM') AS month,
           COUNT(*)            AS admissions,
           SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
)
SELECT * FROM monthly
ORDER BY month;


-- J7. Create a final report using multiple CTEs and at least one JOIN.
WITH hospital_stats AS (
    SELECT hospital_id, COUNT(*) AS patients, SUM(treatment_cost) AS total_cost
    FROM patients GROUP BY hospital_id
),
emergency_stats AS (
    SELECT hospital_id, COUNT(*) AS emergency_cases
    FROM patients WHERE admission_type = 'Emergency' GROUP BY hospital_id
)
SELECT h.hospital_name, s.patients, e.emergency_cases, s.total_cost
FROM hospitals h
JOIN hospital_stats  s ON s.hospital_id = h.hospital_id
JOIN emergency_stats e ON e.hospital_id = h.hospital_id
ORDER BY s.total_cost DESC;


-- ============================================================
-- SECTION K: Window Functions
-- ============================================================

-- K1. Use ROW_NUMBER() to number all records by a relevant metric.
SELECT patient_id, patient_name, treatment_cost,
       ROW_NUMBER() OVER (ORDER BY treatment_cost DESC) AS row_no
FROM patients;


-- K2. Use ROW_NUMBER() with PARTITION BY category/entity group.
SELECT medical_condition, patient_id, treatment_cost,
       ROW_NUMBER() OVER (PARTITION BY medical_condition
                          ORDER BY treatment_cost DESC) AS row_no
FROM patients
ORDER BY medical_condition, row_no;


-- K3. Use RANK() to rank entities by a metric.
SELECT city, SUM(treatment_cost) AS total_cost,
       RANK() OVER (ORDER BY SUM(treatment_cost) DESC) AS cost_rank
FROM patients
GROUP BY city;


-- K4. Compare RANK() and DENSE_RANK() when ties exist.
SELECT blood_group, COUNT(*) AS patients,
       RANK()       OVER (ORDER BY COUNT(*) DESC) AS rank_no,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dense_rank_no
FROM patients
GROUP BY blood_group;


-- K5. Find the top 3 entities in each category.
SELECT medical_condition, patient_id, patient_name, treatment_cost, rn
FROM (
    SELECT medical_condition, patient_id, patient_name, treatment_cost,
           ROW_NUMBER() OVER (PARTITION BY medical_condition
                              ORDER BY treatment_cost DESC) AS rn
    FROM patients
) t
WHERE rn <= 3
ORDER BY medical_condition, rn;


-- K6. Find the highest-value record in each category.
SELECT admission_type, patient_id, patient_name, treatment_cost
FROM (
    SELECT admission_type, patient_id, patient_name, treatment_cost,
           ROW_NUMBER() OVER (PARTITION BY admission_type
                              ORDER BY treatment_cost DESC) AS rn
    FROM patients
) t
WHERE rn = 1;


-- K7. Find the second-highest value in each category.
SELECT medical_condition, patient_id, patient_name, treatment_cost
FROM (
    SELECT medical_condition, patient_id, patient_name, treatment_cost,
           DENSE_RANK() OVER (PARTITION BY medical_condition
                              ORDER BY treatment_cost DESC) AS dr
    FROM patients
) t
WHERE dr = 2
ORDER BY medical_condition;


-- K8. Calculate a running total ordered by date.
WITH daily AS (
    SELECT admission_date, SUM(treatment_cost) AS daily_cost
    FROM patients
    GROUP BY admission_date
)
SELECT admission_date, daily_cost,
       SUM(daily_cost) OVER (ORDER BY admission_date) AS running_total
FROM daily
ORDER BY admission_date;


-- K9. Use LAG() to compare current and previous value.
WITH monthly AS (
    SELECT TO_CHAR(admission_date, 'YYYY-MM') AS month,
           SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
)
SELECT month, total_cost,
       LAG(total_cost) OVER (ORDER BY month) AS previous_month_cost
FROM monthly
ORDER BY month;


-- K10. Use LEAD() to compare current and next value.
WITH monthly AS (
    SELECT TO_CHAR(admission_date, 'YYYY-MM') AS month,
           SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
)
SELECT month, total_cost,
       LEAD(total_cost) OVER (ORDER BY month) AS next_month_cost
FROM monthly
ORDER BY month;


-- K11. Calculate current-minus-previous using LAG().
WITH monthly AS (
    SELECT TO_CHAR(admission_date, 'YYYY-MM') AS month,
           SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
)
SELECT month, total_cost,
       total_cost - LAG(total_cost) OVER (ORDER BY month) AS change_from_previous
FROM monthly
ORDER BY month;


-- K12. Use a CTE + window function to create a top-entities-per-category report.
WITH city_condition AS (
    SELECT medical_condition, city, SUM(treatment_cost) AS total_cost
    FROM patients
    GROUP BY medical_condition, city
),
ranked AS (
    SELECT medical_condition, city, total_cost,
           RANK() OVER (PARTITION BY medical_condition
                        ORDER BY total_cost DESC) AS city_rank
    FROM city_condition
)
SELECT medical_condition, city, total_cost, city_rank
FROM ranked
WHERE city_rank <= 3
ORDER BY medical_condition, city_rank;


-- ============================================================
-- SECTION L: Healthcare Business Practice
-- ============================================================

-- L1. Count patients/users/visits/appointments/claims.
SELECT COUNT(*)                                             AS total_admissions,
       COUNT(DISTINCT city)                                 AS cities,
       SUM(CASE WHEN admission_type = 'Emergency' THEN 1 ELSE 0 END) AS emergency_admissions,
       SUM(CASE WHEN readmission = 'Yes' THEN 1 ELSE 0 END)          AS readmissions
FROM patients;


-- L2. Find average age or another suitable patient metric.
SELECT gender,
       COUNT(*)                  AS patients,
       ROUND(AVG(age),1)         AS avg_age,
       ROUND(AVG(bmi),1)         AS avg_bmi,
       ROUND(AVG(length_of_stay),1) AS avg_stay_days
FROM patients
GROUP BY gender;


-- L3. Find total billing/claim/medical expense value.
SELECT insurance_type,
       COUNT(*)            AS patients,
       SUM(treatment_cost) AS total_billing
FROM patients
GROUP BY insurance_type
ORDER BY total_billing DESC;


-- L4. Find activity by doctor, department, hospital or category.
SELECT d.doctor_name,
       COUNT(*)                     AS patients,
       SUM(p.treatment_cost)        AS total_billing,
       ROUND(AVG(p.length_of_stay),1) AS avg_stay_days
FROM patients p
JOIN doctors d ON p.doctor_id = d.doctor_id
GROUP BY d.doctor_name
ORDER BY patients DESC;


-- L5. Find patients/entities with no appointment/visit/claim/record.
SELECT h.hospital_name, COUNT(*) AS patients_without_readmission
FROM patients p
JOIN hospitals h ON p.hospital_id = h.hospital_id
LEFT JOIN readmission_log r ON p.patient_id = r.patient_id
WHERE r.record_id IS NULL
GROUP BY h.hospital_name
ORDER BY patients_without_readmission DESC;


-- L6. Find the month with the highest activity or billing.
SELECT TO_CHAR(admission_date, 'YYYY-MM') AS month,
       COUNT(*)            AS admissions,
       SUM(treatment_cost) AS total_billing
FROM patients
GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
ORDER BY total_billing DESC
LIMIT 1;


-- L7. Find the highest-cost/highest-billed category or entity.
SELECT medical_condition,
       SUM(treatment_cost)          AS total_billing,
       ROUND(AVG(treatment_cost),2) AS avg_cost
FROM patients
GROUP BY medical_condition
ORDER BY total_billing DESC
LIMIT 3;


-- L8. Create a final patient/entity summary using JOIN + CTE.
WITH readmit AS (
    SELECT patient_id, COUNT(*) AS readmission_count
    FROM readmission_log
    GROUP BY patient_id
)
SELECT p.patient_id, p.patient_name, d.doctor_name, h.hospital_name,
       p.treatment_cost, COALESCE(r.readmission_count, 0) AS readmissions
FROM patients p
JOIN doctors   d ON p.doctor_id   = d.doctor_id
JOIN hospitals h ON p.hospital_id = h.hospital_id
LEFT JOIN readmit r ON p.patient_id = r.patient_id
ORDER BY p.treatment_cost DESC;


-- L9. Write 5 business insights from your SQL results.
-- See the business insights page in the Word report (5 insights).