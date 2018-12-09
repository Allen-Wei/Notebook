

The following SQL will get you the row count of all tables in a database:
```sql
CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY table_name, row_count DESC
DROP TABLE #counts
```
The output will be a list of tables and their row counts.

If you just want the total row count across the whole database, appending:

  SELECT SUM(row_count) AS total_row_count FROM #counts

will get you a single value for the total number of rows in the whole database.

Ref: [How to fetch the row count for all tables in a SQL SERVER database](https://stackoverflow.com/questions/2221555/how-to-fetch-the-row-count-for-all-tables-in-a-sql-server-database)
