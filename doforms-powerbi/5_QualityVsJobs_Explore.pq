// =====================================================================
// STEP A — LOAD "Quality vs Jobs.csv" AND SHOW ITS SHAPE
// ---------------------------------------------------------------------
// Run this first, then send me the ColumnName list it produces so the
// gang summary can be written against your real column names.
//
// USE: Home > Get Data > Blank Query > Advanced Editor > paste > Done.
//      (No credential prompt: a local file uses your Windows account.)
// =====================================================================
let
    CsvPath = "C:\Users\suuji\Downloads\Quality vs Jobs.csv",

    Source    = Csv.Document(
                    File.Contents(CsvPath),
                    [ Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv ]),
    Promoted  = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // one row per column: name, detected type, and a sample value
    Names     = Table.ColumnNames(Promoted),
    Profile   = Table.FromList(Names, Splitter.SplitByNothing(), {"ColumnName"}),
    WithType  = Table.AddColumn(Profile, "DetectedType",
                    each Type.ToText(Value.Type(Table.Column(Promoted, [ColumnName]){0}?)) ),
    WithSample= Table.AddColumn(WithType, "SampleValue",
                    each try Text.From(Table.Column(Promoted, [ColumnName]){0}) otherwise null),
    WithCount = Table.AddColumn(WithSample, "DistinctValues",
                    each List.Count(List.Distinct(Table.Column(Promoted, [ColumnName]))), Int64.Type)
in
    WithCount
