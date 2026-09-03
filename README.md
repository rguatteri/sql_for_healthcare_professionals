# SQL for Healthcare Professionals

This repository contains PostgreSQL implementations of the final project from the LinkedIn Learning course [SQL for Healthcare Professionals](https://www.linkedin.com/learning-login/share?forceAccount=false&redirect=https%3A%2F%2Fwww.linkedin.com%2Flearning%2Fsql-for-healthcare-professionals%3Ftrk%3Dshare_ent_url%26shareId%3D8Ql8AgwDQnWmtkJD99ZSUw%253D%253D), taught by Thais Cooke. The project applies SQL to a healthcare analytics scenario: transforming clinical data into actionable insights that can support resource allocation, service delivery, and patient care.

> ⚠️ Course demonstrations used Microsoft SQL Server and SQL Server Management Studio (SSMS). As I was not proficient in using them, I completed this project in **PostgreSQL**, using **pgAdmin 4** for database administration and **Visual Studio Code** for query development.

## Contents

| Directory | Description |
|---|---|
| [`01_setup/`](01_setup/) | PostgreSQL database setup, data preparation and import |
| [`02_queries/`](02_queries/) | Healthcare-oriented SQL queries and implementation notes |
| [`03_dates_handling/`](03_dates_handling/) | Date and time handling in PostgreSQL and SQL Server-to-PostgreSQL equivalent functions |

## Background: Healthcare Analytics Scenario

As a healthcare data analyst, I was asked to support strategic decision-making at a local hospital. The hospital management team recently expressed concerns about resource allocation and patient-care efficiency across multiple departments, and needed actionable insights into patient demographics, diagnoses, laboratory results, appointments, and longitudinal visit patterns. The goal is to optimize resource allocation and service delivery, and enhance patient outcomes.

## Questions Addressed

The analysis addresses the following questions.

| SQL file | Analysis area | Question |
|---|---|---|
| [`01_demographics.sql`](02_queries/01_demographics.sql) | Patient demographics | What is the demographic profile of the patient population, including age and gender distribution? |
| [`02_demographics_diagnosis.sql`](02_queries/02_demographics_diagnosis.sql) | Demographics and diagnoses | Which diagnoses are most prevalent, and how do they vary across gender and age groups? |
| [`03_appointments.sql`](02_queries/03_appointments.sql) | Appointment patterns | What appointment times are most common, and how is appointment volume distributed throughout the day? |
| [`04_laboratory.sql`](02_queries/04_laboratory.sql) | Laboratory testing | Which laboratory tests are ordered most often? |
| [`05_laboratory_risk.sql`](02_queries/05_laboratory_risk.sql) | Blood-sugar risk | Which patients have fasting blood sugar levels outside the normal 70–100 mg/dL range and may warrant early intervention? |
| [`06_risk.sql`](02_queries/06_risk.sql) | Cardiovascular risk stratification | How can patients be grouped into high, medium, and low cardiovascular-risk categories using smoking status and any recorded diabetes/hypertension diagnosis? |
| [`07_readmissions.sql`](02_queries/07_readmissions.sql) | Readmissions | Which patients returned within 30 days of an earlier visit, and what were the dates, reasons, and elapsed days between the paired visits? |

### Age Group Definitions

[`01_demographics.sql`](02_queries/01_demographics.sql) categorises patients as Pediatric, Adult, or Senior based on their age.

| Category | Definition |
|---|---|
| Pediatric | Younger than 18 years |
| Adult | 18–64 years |
| Senior | 65 years or older |

### Cardiovascular Risk Definitions

[`06_risk.sql`](02_queries/06_risk.sql) categorises patients into High, Medium, and Low Risk groups based on their smoking status and any recorded diabetes/hypertension diagnosis.

| Category | Definition |
|---|---|
| High Risk | Smoker with at least one diagnosis of diabetes or hypertension |
| Medium Risk | Non-smoker with at least one diagnosis of diabetes or hypertension |
| Low Risk | Non-smoker with no diagnosis of diabetes or hypertension |

> ⚠️ Risk classification is calculated at the **patient level**, rather than independently for every visit. This is essential because one patient can have multiple visits, and a qualifying diagnosis may appear on only some of them.

## Input Data

Five course-provided workbooks (`.xlsx` files) were used to build the local PostgreSQL database (upon conversion to CSV). The documentation below records their structure and representative first five entries.

> **N.B.** The source files are not included in this repository to respect the course creator's materials. All data shown below are sample records from the source files used to document the project structure.

### `appointment_analysis`

This table stores appointment scheduling and timing data about 87 visits, supporting the analysis of department-specific appointments and appointment-time distributions.

| Column | Description |
|---|---|
| `visit_id` | Unique appointment identifier, linking the result to an outpatient visit |
| `patient_id` | Patient identifier |
| `department_name` | Hospital department handling the appointment |
| `patient_name` | Patient's full name |
| `appointment_date` | Scheduled appointment date |
| `arrival_time` | Patient arrival time |
| `appointment_time` | Scheduled appointment time |
| `admission_time` | Recorded admission/check-in time |

| visit_id | patient_id | department_name | patient_name | appointment_date | arrival_time | appointment_time | admission_time |
|---:|---:|---|---|---|---|---|---|
| 1075 | 521020 | Orthopedics | Matthew Martinez | 2024-06-22 | 08:15 AM | 08:30 AM | 08:20 AM |
| 1081 | 521025 | Orthopedics | Amelia Carter | 2024-06-29 | 08:45 AM | 09:00 AM | 08:52 AM |
| 1091 | 521006 | Cardiology | Janette Wilson | 2024-07-09 | 10:30 AM | 11:00 AM | 10:35 AM |
| 1117 | 521014 | Oncology | Abigail Flores | 2024-08-03 | 09:00 AM | 09:30 AM | 09:10 AM |
| 1123 | 521002 | Cardiology | Michael Smith | 2024-08-10 | 10:15 AM | 11:00 AM | 10:20 AM |

### `hospital_records`

This table stores 90 patient-level records containing BMI, family history, department, and length-of-stay information. It is provided to enrich patient-level healthcare analyses.

| Column | Description |
|---|---|
| `patient_id` | Patient identifier |
| `patient_name` | Patient's full name |
| `bmi` | Body mass index |
| `family_history_of_hypertension` | Indicator of family history of hypertension |
| `department_name` | Associated hospital department |
| `Days_in_the_hospital` | Number of days spent in hospital |

| patient_id | patient_name | bmi | family_history_of_hypertension | department_name | Days_in_the_hospital |
|---:|---|---:|---|---|---:|
| 521001 | Emma Johnson | 19 | Yes | Oncology | 4 |
| 521002 | Michael Smith | 30 | No | Cardiology | 10 |
| 521003 | Emily Williams | 22 | Yes | Neurology | 0 |
| 521004 | William Jones | 28 | No | Oncology | 10 |
| 521005 | Sophia Davis | 19 | No | Orthopedics | 2 |

### `lab_results`

This table stores the results of 380 laboratory tests linked to outpatient visits, supporting the identification of frequently ordered tests and screening for abnormal fasting blood sugar values.

| Column | Description |
|---|---|
| `result_id` | Unique laboratory-result identifier |
| `visit_id` | Appointment identifier, linking the result to an outpatient visit |
| `test_name` | Name of the laboratory test |
| `test_date` | Date of the test |
| `result_value` | Numeric result value |

| result_id | visit_id | test_name | test_date | result_value |
|---:|---:|---|---|---:|
| 20001 | 10034 | Chloride | 2023-01-17 | 96.00 |
| 20002 | 10034 | Hemoglobin A1C | 2023-01-15 | 3.60 |
| 20003 | 10034 | Fasting Blood Sugar | 2023-01-15 | 79.68 |
| 20004 | 10034 | Uric Acid | 2023-01-15 | 8.48 |
| 20005 | 10037 | Uric Acid | 2023-01-20 | 7.90 |

### `outpatient_visits`

This table stores longitudinal outpatient-visit data about 449 individual visits, supporting diagnosis, risk-classification, and readmission analyses.

| Column | Description |
|---|---|
| `visit_id` | Unique outpatient-visit identifier |
| `patient_id` | Patient identifier` |
| `visit_date` | Date of the outpatient visit |
| `doctor_name` | Treating clinician's name |
| `reason_for_visit` | Stated reason for the visit |
| `diagnosis` | Diagnosis recorded for that visit |
| `medication_prescribed` | Medication prescribed at the visit |
| `smoker_status` | Smoking-status indicator (`Y` = smoker; `N` = non-smoker) |

| visit_id | patient_id | visit_date | doctor_name | reason_for_visit | diagnosis | medication_prescribed | smoker_status |
|---:|---:|---|---|---|---|---|---|
| 10072 | 521001 | 30/03/2023 | Dr. Lee | Annual physical | Diabetes | Insulin | Y |
| 10244 | 521001 | 05/01/2024 | Dr. Smith | Checkup | Diabetes | Insulin | Y |
| 10417 | 521001 | 30/09/2024 | Dr. Lee | Diabetes check | Diabetes | Insulin | Y |
| 10437 | 521001 | 05/11/2024 | Dr. Martinez | Back pain | Muscle Injury | Ibuprofen | Y |
| 10079 | 521002 | 05/04/2023 | Dr. Johnson | Annual physical | Hypertension | Metoprolol | Y |

### `patients_table`

This table stores demographic data about 100 patients, providing the core patient identifier used to join demographic information to visit and hospital-record tables.

| Column | Description |
|---|---|
| `patient_id` | Unique patient identifier |
| `patient_name` | Patient's full name |
| `date_of_birth` | Date of birth |
| `gender` | Recorded gender |
| `address` | Patient address |

| patient_id | patient_name | date_of_birth | gender | address |
|---:|---|---|---|---|
| 521001 | Emma Johnson | 1969-05-15 | Female | 1223 Main St, Cityville |
| 521002 | Michael Smith | 1975-09-20 | Male | 4536 Elm St, Townburg |
| 521003 | Emily Williams | 1990-02-10 | Female | 789 Oak Ave, Villagetown |
| 521004 | William Jones | 1988-07-02 | Male | 567 Maple Dr, Countryside |
| 521005 | Sophia Davis | 1979-12-30 | Female | 890 Cherry Ln, Hillside |

## Implementation Notes

### Data Preparation

Importing source files to PostgreSQL/pgAdmin 4 required some workarounds:

- The source workbooks were converted from `.xlsx` to CSV before import;
- Dates were standardised to `YYYY-MM-DD` for PostgreSQL `DATE` fields;
- The source `outpatient_visits` data contained missing `diagnosis` and `medication_prescribed` values; these were replaced with `N/A` for educational purposes.

See [`01_setup/README.md`](01_setup/README.md) for the complete reproducible setup and loading process.

### PostgreSQL Dates' Adaptation

The course used SQL Server syntax in its demonstrations. The main adaptations made for PostgreSQL include:

| SQL Server concept | PostgreSQL approach |
|---|---|
| `GETDATE()` | `LOCALTIMESTAMP`, `NOW()`, or `CURRENT_TIMESTAMP`, depending on time-zone requirements |
| `DATEPART()` | `EXTRACT()` or `date_part()` |
| `DATENAME()` | `to_char()` for names; `EXTRACT()` for numeric components |
| `DATEDIFF(day, start, end)` | Direct date subtraction: `end_date - start_date` |

See [`03_dates_handling/README.md`](03_dates_handling/README.md) for examples and implementation details.

### Analytical Considerations

`COUNT(*)` counts query-result rows. When a patient has multiple visits, it counts visit rows rather than unique patients. `COUNT(DISTINCT patient_id)` prevents this by counting unique patients within a group, however, patients can still appear in multiple groups if classification is performed at visit level.

[`06_risk.sql`](02_queries/06_risk.sql) avoids this issue by first aggregating to one row per patient, using `BOOL_OR()` to identify any qualifying diabetes/hypertension diagnosis across a patient's visits. [`07_readmissions.sql`](02_queries/07_readmissions.sql) uses a self-join on outpatient visits to compare a patient's earlier and later visits, retaining only later visits occurring within 30 days.

See [`02_queries/README.md`](02_queries/README.md) for detailed technical notes on grouping, counting, custom ordering, and patient-level risk classification.

## Disclaimer

This repository is for learning and portfolio purposes only. It uses an educational course dataset, and the analyses are demonstrations of SQL techniques, not clinical decision-support tools or medical advice.
