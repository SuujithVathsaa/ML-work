# Writing Confirm Data Sources

Sources: the v22 Reporting manual, pp.51–70, and the council's own experience **[live]**.

## Hard rules

1. **One SQL statement starting with `SELECT`.** `WITH` is rejected **[live]**. A leading comment probably is too,
   so paste from `SELECT` onward. Inline views in `FROM` and `UNION` are allowed; the manual's validation examples
   use `UNION`.
2. **Oracle dialect.**
   - Use `LENGTH`, not `LEN` **[manual p.63]**.
   - No `AS` before a table alias in a `JOIN` **[manual p.61]**. `AS` before a column alias is fine.
   - Both `JOIN … ON` and comma joins with `(+)` work.
3. **The Wizard overwrites hand-written SQL.** Don't run it on a Data Source you typed by hand **[manual p.56]**.
4. **Column order is a contract.** Once a Data Source is used by a saved qualification, report template, dashboard
   widget or alert, changing the order or data type of a column makes Confirm ask you to remap every column.
   Always **add new columns at the end** **[manual p.58]**.
5. **Column names default to the SQL name.** Renaming a column in the grid is lost if an earlier SELECT item
   changes **[manual p.53]**.
6. **Data types shown are CHAR(n), DECIMAL(n) and DATETIME** **[manual p.53]**.

## Confirm functions you can use in the SQL

| Function | Use |
|---|---|
| `EffectiveDate()` / `EffectiveDateTime()` | Today, or the scheduled run date. A user can override it at run time. Prefer it to `SYSDATE` in scheduled reports. |
| `DefaultDate()` | 1 Jan 1900, Confirm's "no date" value |
| `CurrentConfirmUser()` | Login name, for "my items" filters (`action_officer.login_name = CurrentConfirmUser()`) |
| `CurrentConfirmUserName()`, `CurrentConfirmUserFullName()`, `CurrentConfirmWorkGroup()` | User context |
| `ChildContainedInParent()`, `ChildIntersectsParent()`, `DistanceFromParent()`, `StartDistanceWithinParent()` … | Spatial checks between parent and child. These need Parent and Child column roles. |

## Making it work on the map and in drill-down

- **Map:** include the feature columns (`site_code`, `plot_number`) and a Linked Table to Feature, or include
  Easting and Northing columns **[manual p.68]**.
- **Drill-down:** add the entity's primary key as a column, then add a Linked Table to the entity table that uses
  that column **[manual p.64]**.
- **Dashboard filtering:** include `action_officer.login_name` to filter by user, or the `data_key` column to
  filter by data key **[manual p.31]**.

## Validation data sources (manual p.62)

- **Message data source:** must return a `Message Text` column and may return an `IsError` column ('Y' means
  error). It also needs a Linked Table to Feature, Job or Order.
- **Delegating data source:** returns a `Data Source Key` column listing other data sources to run.

## Finding table and column names

- The schema diagrams are in `sources/schema_diagrams/`.
- Confirm's own **Edit ▸ Copy SQL** menu option copies the SQL behind most screens.
- The **Reporting ▸ Schema Report** menu option lists the schema.
- If you start the Wizard from the Feature table, measurements, date types and text attributes appear under an
  "Attributes" folder.
