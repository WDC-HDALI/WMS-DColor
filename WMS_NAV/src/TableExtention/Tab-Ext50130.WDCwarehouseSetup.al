tableextension 50130 WDCwarehouseSetup extends "Warehouse Setup"
{
    fields
    {
        field(50100; "WMS Journal Template Name"; Code[10])
        {
            Caption = 'WMS Journal Template Name';
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Template";
        }
        field(50101; "WMS Journal Batch Name"; Code[10])
        {
            Caption = 'WMS Journal Batch Name';
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Batch".Name;//where("Journal Template Name" = field("WMS Journal Template Name"));
        }
        field(50102; "Email error BC-WMS"; Text[250])
        {
            Caption = '"Email error BC-WMS"';
            DataClassification = ToBeClassified;
        }

    }
}
