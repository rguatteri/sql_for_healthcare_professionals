# Healthcare SQL queries

This directory contains the PostgreSQL queries I developed while completing the LinkedIn Learning course [SQL for Healthcare Professionals](https://www.linkedin.com/learning-login/share?forceAccount=false&redirect=https%3A%2F%2Fwww.linkedin.com%2Flearning%2Fsql-for-healthcare-professionals%3Ftrk%3Dshare_ent_url%26shareId%3D8Ql8AgwDQnWmtkJD99ZSUw%253D%253D), taught by Thais Cooke. These scripts were adapted and executed against the local PostgreSQL database, which I set up as described in [`../01_setup/`](../01_setup/).

> Query-level analytical objectives are documented in the repository's main README. Here I focus on the query structure, execution context, and PostgreSQL-specific technical notes, with a focus on [`01_demographics.sql`](01_demographics.sql) and [`06_risk.sql`](06_risk.sql).

> ⚠️ Course demonstrations used Microsoft SQL Server and SQL Server Management Studio (SSMS). As I was not proficient in using them, I completed this project in **PostgreSQL**, using **pgAdmin 4** for database administration and **Visual Studio Code** for query development.

## Contents

| File | Topic |
|---|---|
| [`01_demographics.sql`](01_demographics.sql) | Demographic profile of patients |
| [`02_demographics_diagnosis.sql`](02_demographics_diagnosis.sql) | Demographic-based analysis of diagnoses |
| [`03_appointments.sql`](03_appointments.sql) | Appointments' frequency and distribution |
| [`04_laboratory.sql`](04_laboratory.sql) | Most commonly ordered lab tests |
| [`05_laboratory_risk.sql`](05_laboratory_risk.sql) | Laboratory results and risk analysis |
| [`06_risk.sql`](06_risk.sql) | Patient-level risk categorisation |
| [`07_readmissions.sql`](07_readmissions.sql) | Readmission analysis |

## Requirements and Conventions

Before running these scripts:

- Complete the database and data-import workflow documented in [`../01_setup/`](../01_setup/);
- Connect to the `sql_healthcare` PostgreSQL database in VS Code, pgAdmin 4, or another PostgreSQL client;
- Run queries against the tables created from the course material;
- Review [`../03_dates_handling/`](../03_dates_handling/) for PostgreSQL adaptations of SQL Server date/time functions.

## Custom Ordering and Grouping

[`01_demographics.sql`](01_demographics.sql) groups patients into the `Pediatric`, `Adult`, and `Senior` age categories. By default, text labels are sorted alphabetically (`Adult`, `Pediatric`, and `Senior`), however, this is not the clinically meaningful order. Instead, the query orders groups by the minimum numeric age within each category:

```sql
ORDER BY MIN(EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)));
```

This `ORDER BY` clause works because the minimum age in the Pediatric group is always lower than the minimum age in the Adult group, which in turn is always lower than the minimum age in the Senior group.

### Alternative Ordering Attempt

Initially, I tried sorting age groups using a custom rank such as:

```sql
CASE age
    WHEN 'Pediatric' THEN 1
    WHEN 'Adult' THEN 2
    ELSE 3
END
```

However, PostgreSQL only permits a select-list alias in `ORDER BY` when the ordering item is the bare alias itself (such as `ORDER BY age`). For an alias to be referenced in an `ORDER BY` clause, the alias itself cannot be embedded inside another expression such as `CASE age ...`.

### General `GROUP BY` Rule

After `GROUP BY`, every non-aggregated expression used in `SELECT`, `HAVING`, or `ORDER BY` must either exactly match a `GROUP BY` expression or be wrapped in an aggregate function such as `COUNT()`, `MIN()`, `MAX()`, `SUM()`, or `AVG()`. 

This is why `MIN(EXTRACT(...))` is valid: `MIN()` aggregates all raw age values inside each group into one value that can be used for ordering.

## Patient-Level Risk Classification

[`06_risk.sql`](06_risk.sql) shows an important distinction between a visit-level table and a patient-level question. A patient can have several outpatient visits, yet only some visits may contain a diagnosis of diabetes or hypertension. Classifying individual visit rows can therefore place the same person in multiple risk categories.

The solution is to aggregate the visit table to **one row per patient** before assigning a mutually exclusive risk category. To this purpose, the script uses:

```sql
BOOL_OR(diagnosis IN ('Diabetes', 'Hypertension'))
```

`BOOL_OR(expression)` returns `TRUE` if the expression is true for at least one row in the group, and `FALSE` otherwise. Here, it answers: *Did this patient receive a qualifying diagnosis on any visit?*

The script also uses:

```sql
MAX(smoker_status)
```

`MAX(smoker_status)` collapses the smoker status value to one value per patient during grouping. This is appropriate for this dataset because `smoker_status` is consistent across the multiple visit records related to a given patient.

### General Classification Rule

Whenever a classification depends on values that may occur on some (but not all) rows belonging to an entity, aggregate to one row per entity before applying mutually exclusive categories. In longitudinal healthcare data, the entity may be a patient, encounter, specimen, or admission; the source table may instead contain multiple visits, claims, laboratory tests, or measurements.

### Counting Rows and Patients

`COUNT(*)` counts every row produced by the query. After joining a patient table to a visit table, this often means it counts visits rather than unique patients, because a patient's demographic information appears once for every matching visit.

Use the measure that matches the analytical question:

| Question | Appropriate expression |
|---|---|
| How many rows/visits are present? | `COUNT(*)` |
| How many non-null values occur in a column? | `COUNT(column_name)` |
| How many unique patients are represented? | `COUNT(DISTINCT patient_id)` |

`COUNT(DISTINCT patient_id)` deduplicates patients only within each group. If a patient qualifies for different groups on different visit rows, first derive a single patient-level category (as in [`06_risk.sql`](06_risk.sql)) before counting.

## Reproducibility Notes

- Run a script in full only when its tables and column names are present in the active database;
- Inspect intermediate results with `LIMIT` while adapting a query or validating an import;
- Use explicit table aliases in joins, particularly self-joins such as the readmission analysis, to make the origin of each column unambiguous;
- Preserve the scripts as `.sql` files so analyses remain readable, version-controlled, and reproducible.
