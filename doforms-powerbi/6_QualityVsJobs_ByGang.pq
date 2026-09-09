// =====================================================================
// STEP B — INSPECTIONS vs JOBS COMPLETED, BY GANG
// ---------------------------------------------------------------------
// Output: one row per gang
//     Gang | Inspections Completed | Jobs Completed | Inspections per Job | Coverage %
//
// *** SET THE FIVE NAMES IN "COLUMN MAPPING" TO MATCH YOUR CSV ***
// Run 5_QualityVsJobs_Explore.pq first to see the real column names.
//
// It supports the two usual CSV shapes:
//   LONG  - one row per record, with a column saying Inspection vs Job
//   WIDE  - one row per gang (or per job) with separate count columns
// Set Shape below to whichever matches.
// =====================================================================
let
    CsvPath = "C:\Users\suuji\Downloads\Quality vs Jobs.csv",
    Shape   = "LONG",          // "LONG" or "WIDE"

    // ---------------- COLUMN MAPPING ----------------
    GangCol       = "Gang",           // the crew / team column
    // LONG shape only:
    TypeCol       = "Type",           // column holding Inspection vs Job
    InspectionTag = "Inspection",     // the value that means an inspection
    JobTag        = "Job",            // the value that means a job
    StatusCol     = "Status",         // completion column ("" = count every row)
    CompletedTag  = "Completed",      // the value that means completed
    // WIDE shape only:
    InspectionsCountCol = "Inspections",
    JobsCountCol        = "Jobs",

    // ---------------- LOAD ----------------
    Source   = Csv.Document(
                   File.Contents(CsvPath),
                   [ Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv ]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // trim stray spaces so "Gang A " and "Gang A" group together
    Trimmed  = Table.TransformColumns(Promoted,
                   List.Transform(Table.ColumnNames(Promoted),
                       each {_, (v) => if v is text then Text.Trim(v) else v})),

    // drop rows with no gang
    HasGang  = Table.SelectRows(Trimmed,
                   each Record.Field(_, GangCol) <> null
                    and Record.Field(_, GangCol) <> ""),

    // ---------------- SUMMARISE ----------------
    // count a row as completed if no status column is configured,
    // or if the status column equals CompletedTag (case-insensitive)
    IsCompleted = (row as record) as logical =>
        if StatusCol = "" then true
        else Comparer.OrdinalIgnoreCase(
                 Text.From(Record.FieldOrDefault(row, StatusCol, "")), CompletedTag) = 0,

    IsOfType = (row as record, tag as text) as logical =>
        Comparer.OrdinalIgnoreCase(
            Text.From(Record.FieldOrDefault(row, TypeCol, "")), tag) = 0,

    SummaryLong =
        Table.Group(HasGang, {GangCol}, {
            { "Inspections Completed",
              each List.Count(List.Select(Table.ToRecords(_),
                       (r) => IsOfType(r, InspectionTag) and IsCompleted(r))), Int64.Type },
            { "Jobs Completed",
              each List.Count(List.Select(Table.ToRecords(_),
                       (r) => IsOfType(r, JobTag) and IsCompleted(r))), Int64.Type }
        }),

    SummaryWide =
        Table.Group(HasGang, {GangCol}, {
            { "Inspections Completed",
              each List.Sum(List.Transform(Table.Column(_, InspectionsCountCol),
                       each try Number.From(_) otherwise 0)), Int64.Type },
            { "Jobs Completed",
              each List.Sum(List.Transform(Table.Column(_, JobsCountCol),
                       each try Number.From(_) otherwise 0)), Int64.Type }
        }),

    Summary = if Shape = "WIDE" then SummaryWide else SummaryLong,

    // ---------------- DERIVED MEASURES ----------------
    // Inspections per Job: quality checks carried out per job done.
    WithRatio = Table.AddColumn(Summary, "Inspections per Job",
                    each if [Jobs Completed] = 0 then null
                         else Number.Round([Inspections Completed] / [Jobs Completed], 2),
                    type number),

    // Coverage %: share of jobs that got an inspection (capped at 100%).
    WithCoverage = Table.AddColumn(WithRatio, "Coverage %",
                    each if [Jobs Completed] = 0 then null
                         else Number.Round(
                                  List.Min({[Inspections Completed] / [Jobs Completed], 1}) * 100, 1),
                    type number),

    Renamed = Table.RenameColumns(WithCoverage, {{GangCol, "Gang"}}),
    Sorted  = Table.Sort(Renamed, {{"Jobs Completed", Order.Descending}})
in
    Sorted
