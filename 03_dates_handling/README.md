# Date and Time Handling in PostgreSQL

This directory documents PostgreSQL equivalents for common SQL Server date and time functions used while completing the LinkedIn Learning course [SQL for Healthcare Professionals](https://www.linkedin.com/learning-login/share?forceAccount=false&redirect=https%3A%2F%2Fwww.linkedin.com%2Flearning%2Fsql-for-healthcare-professionals%3Ftrk%3Dshare_ent_url%26shareId%3D8Ql8AgwDQnWmtkJD99ZSUw%253D%253D).

> ⚠️ Course demonstrations used Microsoft SQL Server and SQL Server Management Studio (SSMS). As I was not proficient in using them, I relied on **PostgreSQL**, **pgAdmin 4**, and **Visual Studio Code**.

## Contents

| File | Purpose |
|---|---|
| [`01_dates_handling.sql`](01_dates_handling.sql) | Example PostgreSQL queries covering current date/time values, date parts, formatted date names, elapsed time, and age calculation. |

## Current Date and Time

| Purpose | SQL Server | PostgreSQL |
|---|---|---|
| Current timestamp, no time-zone offset | `GETDATE()` | `LOCALTIMESTAMP` |
| Current timestamp with time-zone information | — | `NOW()` or `CURRENT_TIMESTAMP` |
| Current date only | `CAST(GETDATE() AS DATE)` | `CURRENT_DATE` |

`GETDATE()` returns SQL Server's current system timestamp as a `datetime` value without a time-zone offset. In PostgreSQL, `LOCALTIMESTAMP` is the closest equivalent because it returns a `timestamp without time zone`, for example `2026-08-25 13:14:44.397821`.

```sql
SELECT LOCALTIMESTAMP AS local_timestamp;
SELECT CURRENT_DATE AS current_date;
```

`NOW()` and `CURRENT_TIMESTAMP` are interchangeable PostgreSQL expressions that return a `timestamp with time zone`, for example `2026-08-25 13:14:44.397821+00`. They represent the start time of the current transaction.

```sql
SELECT NOW() AS current_timestamp;
-- Equivalent:
SELECT CURRENT_TIMESTAMP AS current_timestamp;
```

## Extract a date part

SQL Server uses `DATEPART(interval, date)`. PostgreSQL provides two equivalents:

```sql
-- SQL Server
SELECT DATEPART(weekday, appointment_date);

-- PostgreSQL
SELECT date_part('dow', appointment_date);
SELECT EXTRACT(DOW FROM appointment_date);
```

`date_part(field, source)` requires the `field` argument to be quoted. In `EXTRACT(field FROM source)`, the field is an unquoted identifier.

| SQL Server datepart | PostgreSQL field |
|---|---|
| `DAYOFYEAR` | `doy` |
| `WEEKDAY` | `dow` |
| `HH` | `hour` |
| `MI` | `minute` |
| `SS` | `second` |

PostgreSQL's `dow` uses `0` for Sunday through `6` for Saturday. SQL Server's `DATEPART(weekday, ...)` numbering depends on `SET DATEFIRST`; with Sunday as the first day, Sunday is `1`, Monday is `2`, and Saturday is `7`.

## Return date names

SQL Server's `DATENAME()` returns a date part as text. PostgreSQL uses `to_char()` for names and `EXTRACT()` for numeric components.

| Task | SQL Server | PostgreSQL |
|---|---|---|
| Full month name | `DATENAME(month, d)` | `trim(to_char(d, 'Month'))` |
| Full weekday name | `DATENAME(weekday, d)` | `trim(to_char(d, 'Day'))` |
| Numeric year | `DATENAME(year, d)` | `EXTRACT(YEAR FROM d)` |
| Numeric day as text | `DATENAME(day, d)` | `CAST(EXTRACT(DAY FROM d) AS TEXT)` |

`to_char()` uses format patterns; their casing controls the output casing. For example, `'Day'`, `'DAY'`, and `'day'` return capitalised, upper-case, and lower-case weekday names, respectively. `'Dy'` returns an abbreviated weekday name.

Patterns such as `Month` and `Day` are blank-padded to nine characters by default. Use `trim()` before displaying, grouping, filtering, or joining on their output.

```sql
SELECT
    trim(to_char(appointment_date, 'Day')) AS weekday_name,
    trim(to_char(appointment_date, 'Month')) AS month_name
FROM appointment_analysis;
```

## Calculate elapsed time

PostgreSQL has no direct `DATEDIFF()` equivalent. The appropriate method depends on the data type and desired unit.

### Difference between `DATE` values

Subtract dates directly, placing the later date first for a positive elapsed-day count.

```sql
-- SQL Server
SELECT DATEDIFF(day, admission_date, discharge_date) AS length_of_stay_days;

-- PostgreSQL
SELECT discharge_date - admission_date AS length_of_stay_days;
```

Literal dates need an explicit date type. Without quotes, `2024-01-10` is treated as an arithmetic expression rather than a date.

```sql
SELECT DATE '2024-01-10' - DATE '2024-01-01' AS date_difference;
-- Returns 9
```

### Difference between `TIMESTAMP` values

Timestamp subtraction returns an `interval`. `EXTRACT(EPOCH FROM ...)` retrieves total elapsed seconds; divide by `60` for minutes or `3600` for hours.

```sql
SELECT
    EXTRACT(EPOCH FROM (check_out_time - check_in_time)) AS elapsed_seconds,
    EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 60 AS elapsed_minutes,
    EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600 AS elapsed_hours
FROM outpatient_visits;
```

## Calculate patient age

This expression calculates age in completed years through integer division:

```sql
SELECT (CURRENT_DATE - date_of_birth) / 365 AS age
FROM patients_table;
```

PostgreSQL truncates the fractional result because both operands are integers: 49.9 years becomes `49`. For a calendar-accurate age that accounts for birthdays and leap years, use `age()`:

```sql
SELECT EXTRACT(YEAR FROM age(date_of_birth)) AS age
FROM patients_table;
```

## Practical guidance

- Use `CURRENT_DATE` for date-only comparisons and `NOW()`/`CURRENT_TIMESTAMP` when time-zone context matters.
- Prefer `EXTRACT()` for readable analytical SQL; use `date_part()` when its function-call style is more convenient.
- Use `trim(to_char(...))` for formatted month/day labels to avoid blank-padding issues.
- For clinical duration measures, distinguish elapsed time (`end - start`) from calendar boundaries crossed; the distinction can alter results.
