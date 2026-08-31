# PostgreSQL setup and data import

This directory documents the setup used to reproduce the analyses from the LinkedIn Learning course *SQL for Healthcare Professionals* in a local PostgreSQL database. The workflow used **PostgreSQL**, **pgAdmin 4**, and **Visual Studio Code** rather than the SQL Server/SSMS environment used in the course demonstrations.

## Contents

| File | Purpose |
|---|---|
| `01_create_tables.sql` | Creates the tables used in the project and assigns ownership to the `postgres` role. |
| `02_modify_tables.sql` | Loads/prepares the project data after file paths have been updated for the local machine. |

## Prerequisites

- PostgreSQL installed and running
- pgAdmin 4
- A PostgreSQL database created for this project (for example, `sql_healthcare`)
- The course `.xlsx` source files downloaded locally

## 1. Prepare the source files

pgAdmin 4's **Import/Export Data** dialog does not import Excel workbooks (`.xlsx`) directly. Its standard import workflow supports CSV, text, and PostgreSQL binary files, and imports data into an **existing table** rather than directly into a database.

Therefore, each course workbook was first converted to **CSV UTF-8 (Comma delimited) (`.csv`)** in Excel. If a workbook has multiple worksheets, export each required worksheet separately.

Before importing a CSV, inspect it in Excel or a text editor:

1. Ensure the first row contains the column names (for example, `patient_id`, `age`, and `diagnosis`).
2. Use clear, unique column names; avoid spaces and unnecessary special characters where possible.
3. Check missing values. In the original `outpatient_visits` file, missing values in `diagnosis` and `medication_prescribed` were replaced with `N/A` before import.
4. Standardise date values. The source CSV files used inconsistent date formats, so all dates were converted to ISO 8601 format: `YYYY-MM-DD`.
5. Ensure identifiers are preserved as intended. In particular, Excel can remove leading zeroes from IDs; this did not affect this project, but it is an important check for other datasets.

> **Note:** Replacing missing values with `N/A` is appropriate for a learning dataset and can make import simpler, but in a production or research workflow, preserving missing values as SQL `NULL` is usually preferable.

## 2. Create the table schemas

Run [`01_create_tables.sql`](01_create_tables.sql) against the project database. The script creates the tables before any data are loaded and assigns their ownership to the `postgres` user.

Choose data types that match the source file:

| Source data | PostgreSQL type |
|---|---|
| Whole numbers | `INTEGER` |
| Decimal numbers | `NUMERIC` |
| Text, labels, and categories | `TEXT` |
| Calendar dates | `DATE` |
| Dates and times | `TIMESTAMP` |

Creating the schema first is important: CSV import tools load rows into a pre-existing table and do not infer a robust table design for you.

## 3. Load CSV data with `psql`

A server-side `COPY` command such as the following initially failed:

```sql
COPY appointment_analysis
FROM 'C:\\Users\\...\\appointment_analysis.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
```

The error was:

```text
ERROR: could not open file "C:\\Users\\...\\appointment_analysis.csv" for reading: Permission denied
```

This happens because `COPY FROM 'file'` is executed by the PostgreSQL **server** process, which needs permission to read that file on the server's filesystem. A local Windows path available to the logged-in user is not necessarily available to the database server.

The successful workaround was to use pgAdmin's **PSQL Tool** and the client-side `\copy` commands in [`02_modify_tables.sql`](02_modify_tables.sql). Unlike `COPY`, `\copy` is run by the `psql` client and reads files using the permissions of the signed-in Windows user.

### Steps

1. If a clean restart is needed, drop the existing database with `DROP DATABASE IF EXISTS ...`, recreate it, and rerun the schema-creation script.
2. Open pgAdmin 4 and navigate to the target database in **Object Explorer**.
3. Right-click the database and select **PSQL Tool**.
4. Obtain the absolute path for every CSV file. In VS Code, right-click the file and select **Copy Path**.
5. Open `02_modify_tables.sql`, replace each placeholder with the correct local path, and paste/run the commands in PSQL Tool.
6. Confirm that the load succeeded by checking the row counts, for example:

```sql
SELECT COUNT(*) AS row_count
FROM appointment_analysis;
```

## Verification checklist

After loading the data, verify that:

- All expected tables appear under the database schema.
- Row counts match the source files.
- Dates load as `DATE` values rather than text.
- Key identifiers, such as `patient_id` and `visit_id`, are present and retain their expected values.
- Queries can be run from VS Code through the PostgreSQL connection.

## Reproducibility and privacy

The CSV source files and absolute local paths are intentionally not committed to this repository. Absolute paths are machine-specific and may disclose usernames or local directory structure. Anyone reproducing this project should download the course material independently, perform the preparation steps above, and update the local paths in `02_modify_tables.sql`.