tableextension 50144 WDCSalesCrMemoline extends "Sales Cr.Memo Line"
{
    fields
    {
        field(50100; "Update WMS Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50101; "Update WMS Time"; time)
        {
            DataClassification = ToBeClassified;
            Editable = false;

        }
    }
}
