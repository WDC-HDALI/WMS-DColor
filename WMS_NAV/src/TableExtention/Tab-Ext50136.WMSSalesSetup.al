tableextension 50136 WMSSalesSetup extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "Order Group Nos."; Code[20])
        {
            Caption = 'Order Group Nos.';
            TableRelation = "No. Series";
        }
        field(50101; "Fodec Percent"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Stamp Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
}
