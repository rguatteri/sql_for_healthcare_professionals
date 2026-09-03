# Date and Time Handling in PostgreSQL

This directory documents PostgreSQL equivalents for common SQL Server date and time functions used while completing the LinkedIn Learning course [SQL for Healthcare Professionals](https://www.linkedin.com/learning-login/share?forceAccount=false&redirect=https%3A%2F%2Fwww.linkedin.com%2Flearning%2Fsql-for-healthcare-professionals%3Ftrk%3Dshare_ent_url%26shareId%3D8Ql8AgwDQnWmtkJD99ZSUw%253D%253D), taught by Thais Cooke.

> ⚠️ Course demonstrations used Microsoft SQL Server and SQL Server Management Studio (SSMS). As I was not proficient in using them, I completed this project in **PostgreSQL**, using **pgAdmin 4** for database administration and **Visual Studio Code** for query development.

## Contents

| File | Purpose |
|---|---|
| [`01_dates_handling.sql`](01_dates_handling.sql) | Example PostgreSQL queries covering current date/time values, date parts, formatted date names, elapsed time, and age calculation. |

## Current Date and Time

| Purpose | SQL Server | PostgreSQL | Example |
|---|---|---|---|
| System's current timestamp without time-zone information | `GETDATE()` | `LOCALTIMESTAMP` | `2026-08-25 13:14:44.397821` |
| System's current timestamp with time-zone information | — | `NOW()` or `CURRENT_TIMESTAMP` | `2026-08-25 13:14:44.397821+00` |
| System's current date only | `CAST(GETDATE() AS DATE)` | `CURRENT_DATE` | `2026-08-25` |

> `GETDATE()` returns SQL Server's current timestamp as a `datetime` value. In PostgreSQL, `LOCALTIMESTAMP` is the closest equivalent because it returns a `timestamp without time zone` value. `NOW()` and `CURRENT_TIMESTAMP` are interchangeable PostgreSQL expressions that return a `timestamp with time zone` value.

### Usage

```sql
SELECT LOCALTIMESTAMP AS system_timestamp;
```

```sql
SELECT NOW() AS system_timestamp;
-- Equivalent:
SELECT CURRENT_TIMESTAMP AS system_timestamp;
```

```sql
SELECT CURRENT_DATE AS system_date;
```

## Extract a Date Part

| Purpose | SQL Server | PostgreSQL |
|---|---|---|
| Extract a date part | `DATEPART(interval, date)` | `DATE_PART('field', source)` or `EXTRACT(field FROM source)` |

SQL Server uses `DATEPART(interval, date)`:
- The `interval` argument is the output that you want the query to retrieve (e.g., weekdays);
- The `date` argument is the column you're retrieving the information from.

PostgreSQL provides two equivalents:

```sql
SELECT DATE_PART(`field`, source);
SELECT EXTRACT(field FROM source);
```

> **N.B.** `DATE_PART(field, source)` requires the `field` argument to be quoted. In contrast, in `EXTRACT(field FROM source)`, `field` is an unquoted identifier.

Some date parts' keywords carry over differently between SQL Server's DATEPART() and PostgreSQL's DATE_PART() and EXTRACT():

| SQL Server | PostgreSQL |
|---|---|
| `DAYOFYEAR` | `doy` |
| `WEEKDAY` | `dow` |
| `HH` | `hour` |
| `MI` | `minute` |
| `SS` | `second` |

> ⚠️ PostgreSQL's `dow` uses `0` for Sunday through `6` for Saturday. In contrast, SQL Server's `DATEPART(weekday, ...)` numbering depends on `SET DATEFIRST`; with Sunday as the first day, Sunday is `1`, Monday is `2`, and Saturday is `7`.

### Usage

```sql
SELECT
    appointment_date,
    DATE_PART('DOW', appointment_date) + 1 AS day_of_the_week
FROM
    appointment_analysis;
```

## Return Date Names

| Task | SQL Server | PostgreSQL |
|---|---|---|
| Named part | `DATENAME(month, d)` | `TRIM(TO_CHAR(d, 'Month'))` |
| Numeric part | `DATENAME(year, d)` | `EXTRACT(YEAR FROM d)` |
| Numeric part as text | `DATENAME(day, d)` | `CAST(EXTRACT(DAY FROM d) AS TEXT)` |

> **N.B.** SQL Server's `DATENAME()` (using the same arguments as `DATEPART()`) always returns a string, whether it is a name (e.g., August for MONTH) or a number (e.g., 26 for DAY). PostgreSQL splits this behavior into two different tools, using `TO_CHAR()` for names and `EXTRACT()` for numeric components. Additionally, `CAST(EXTRACT() AS TEXT)` can be used to obtain a numeric part as text.

`TO_CHAR()` uses format patterns, hence their casing controls the output casing. For example, `'Day'`, `'DAY'`, and `'day'` return capitalised, upper-case, and lower-case weekday names, respectively. `'Dy'` returns an abbreviated weekday name.

| Pattern | Example Output |
|---|---|
| `Day` | `Monday` |
| `DAY` | `MONDAY` |
| `Dy` | `Mon` |
| `dy` | `mon` |

> `TO_CHAR()`'s `Month` and `Day` patterns are blank-padded to nine characters by default. For instance, 'August' actually comes back as 'August ' (i.e., with trailing spaces). To address this issue, use `TRIM()` before displaying, grouping, filtering, or joining on their output.

### Usage

```sql
SELECT
    appointment_date,
    TRIM(TO_CHAR(appointment_date, 'Day')) AS day_of_the_week
FROM appointment_analysis;
```

## Compute Elapsed Time

PostgreSQL has no direct `DATEDIFF()` equivalent. The appropriate method to compute elapsed time depends on the data type and desired unit.

### Difference between `DATE` values

Subtract dates directly, placing the later date first for a positive elapsed-day count.

```sql
SELECT
    (later_date - earlier_date) AS date_difference
FROM
    table;
```

Subtracting literal dates (instead of referencing columns that are already typed as date or timestamp) needs these dates to be explicitly casted. Without quotes, `2024-01-10` is treated as an arithmetic expression rather than a date.

```sql
SELECT
    (DATE '2024-01-10' - DATE '2024-01-01') AS date_difference;
-- Returns 9
```

### Difference between `TIMESTAMP` values

Timestamp subtraction returns an `interval`. `EXTRACT(EPOCH FROM ...)` retrieves total elapsed seconds: divide by `60` for minutes or `3600` for hours.

```sql
SELECT
    EXTRACT(EPOCH FROM (check_out_time - check_in_time)) AS elapsed_seconds,
    EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 60 AS elapsed_minutes,
    EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600 AS elapsed_hours
FROM outpatient_visits;
```

```sql
SELECT
    appointment_time,
    arrival_time,
    ROUND((EXTRACT(EPOCH FROM (appointment_time - arrival_time)) / 60), 0) AS minutes_difference
FROM
    appointment_analysis;
```

## Compute Age

This expression calculates age in completed years through integer division:

```sql
SELECT
    (CURRENT_DATE - date_of_birth) / 365 AS age
FROM
    patients_table;
```

> **N.B.** PostgreSQL truncates the fractional result because both operands are integers: 49.9 years becomes `49`. For a calendar-accurate age that accounts for birthdays and leap years, use `AGE()`.

```sql
SELECT
    EXTRACT(YEAR FROM AGE(date_of_birth)) AS age
FROM
    patients_table;
```

## Practical Guidance

- Use `CURRENT_DATE` for date-only comparisons and `NOW()`/`CURRENT_TIMESTAMP` when time-zone context matters;
- Prefer `EXTRACT()` for readable analytical SQL; use `DATE_PART()` when its function-call style is more convenient;
- Use `TRIM(TO_CHAR(...))` for formatted month/day labels to avoid blank-padding issues;
- For clinical duration measures, distinguish elapsed time (`end - start`) from calendar boundaries crossed; the distinction can alter results.
