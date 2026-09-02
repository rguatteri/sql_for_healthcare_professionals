# Healthcare SQL queries

This directory contains the PostgreSQL queries developed while completing the *SQL for Healthcare Professionals* course. The course demonstrations use SQL Server/T-SQL; these scripts were adapted and executed against the local PostgreSQL database described in [`../01_setup/`](../01_setup/).

The query-level analytical objectives are documented in the repository's main README. This directory README focuses on the query structure, execution context, and PostgreSQL-specific technical notes.

## Contents

| File | Topic |
|---|---|
| [`01_demographics.sql`](01_demographics.sql) | Patient demographics and age groups |
| [`02_demographics_diagnosis.sql`](02_demographics_diagnosis.sql) | Demographic and diagnosis-based analysis |
| [`03_appointments.sql`](03_appointments.sql) | Appointment-related analysis |
| [`04_laboratory.sql`](04_laboratory.sql) | Laboratory-data analysis |
| [`05_laboratory_risk.sql`](05_laboratory_risk.sql) | Laboratory results and risk analysis |
| [`06_risk.sql`](06_risk.sql) | Patient-level risk categorisation |
| [`07_readmissions.sql`](07_readmissions.sql) | Readmission analysis using visit data |

## Requirements and conventions

Before running these scripts:

- Complete the database and data-import workflow documented in [`../01_setup/README.md`](../01_setup/README.md).
- Connect to the `sql_healthcare` PostgreSQL database in VS Code, pgAdmin 4, or another PostgreSQL client.
- Run queries against the tables created from the course material.
- Review [`../03_dates_handling/README.md`](../03_dates_handling/README.md) for PostgreSQL adaptations of SQL Server date/time functions.

The scripts use PostgreSQL syntax and make deliberate use of aliases, `CASE`, joins, grouping, aggregate functions, and date/time expressions. SQL identifiers are written in lower case and use underscores, matching PostgreSQL conventions.

## Grouping and custom ordering

`01_demographics.sql` groups patients into the `Pediatric`, `Adult`, and `Senior` age categories. Text labels sort alphabetically by default, which would produce `Adult`, `Pediatric`, then `Senior`; this is not the clinically meaningful order.

The query instead orders groups by the minimum numeric age within each category:

```sql
ORDER BY MIN(EXTRACT(YEAR FROM age(CURRENT_DATE, date_of_birth)));
```

This works because the minimum age in the Pediatric group is always less than the minimum age in the Adult group, which is always less than the minimum age in the Senior group.

An initially considered alternative was a custom rank such as:

```sql
CASE age
    WHEN 'Pediatric' THEN 1
    WHEN 'Adult' THEN 2
    ELSE 3
END
```

However, PostgreSQL only permits a select-list alias in `ORDER BY` when the ordering item is the bare alias itself—for example, `ORDER BY age`. An alias cannot be embedded inside another expression such as `CASE age ...` at the same query level.

### `GROUP BY` rule

After `GROUP BY`, every non-aggregated expression used in `SELECT`, `HAVING`, or `ORDER BY` must exactly match a grouping expression. Alternatively, it must be wrapped in an aggregate function such as `COUNT()`, `MIN()`, `MAX()`, `SUM()`, or `AVG()`.

This is why `MIN(EXTRACT(...))` is valid: `MIN()` aggregates all raw age values inside each group into one value that can be used for ordering.

## Patient-level risk classification

`06_risk.sql` shows an important distinction between a visit-level table and a patient-level question. A patient can have several outpatient visits, and only some visits may contain a diagnosis of diabetes or hypertension. Classifying individual visit rows can therefore place the same person in both a qualifying risk category and `Low Risk`.

The solution is to aggregate the visit table to **one row per patient** before assigning a mutually exclusive risk category. The script uses:

```sql
BOOL_OR(diagnosis IN ('Diabetes', 'Hypertension'))
```

`BOOL_OR(expression)` returns `TRUE` if the expression is true for at least one row in the group; here, it answers: *Did this patient receive a qualifying diagnosis on any visit?*

The script also uses:

```sql
MAX(smoker_status)
```

`MAX(smoker_status)` reduces the smoking-status value to one value per patient during grouping. This is appropriate for this dataset because `smoker_status` is consistent across the multiple visit records belonging to a given patient.

### General rule

Whenever a classification depends on values that may occur on some, but not all, rows belonging to an entity, aggregate to one row per entity before applying mutually exclusive categories. In longitudinal healthcare data, the entity may be a patient, encounter, specimen, or admission; the source table may instead contain multiple visits, claims, laboratory tests, or measurements.

## Counting rows and patients

`COUNT(*)` counts every row produced by the query. After joining a patient table to a visit table, this often means it counts visits rather than unique patients, because a patient's demographic information appears once for every matching visit.

Use the measure that matches the analytical question:

| Question | Appropriate expression |
|---|---|
| How many rows/visits are present? | `COUNT(*)` |
| How many non-null values occur in a column? | `COUNT(column_name)` |
| How many unique patients are represented? | `COUNT(DISTINCT patient_id)` |

`COUNT(DISTINCT patient_id)` deduplicates patients only within each group. If a patient qualifies for different groups on different visit rows, first derive a single patient-level category, as in `06_risk.sql`, before counting.

## Reproducibility notes

- Run a script in full only when its tables and column names are present in the active database.
- Inspect intermediate results with `LIMIT` while adapting a query or validating an import.
- Use explicit table aliases in joins, particularly self-joins such as the readmission analysis, to make the origin of each column unambiguous.
- Preserve the scripts as `.sql` files so analyses remain readable, version-controlled, and reproducible.
