tableextension 50145 "WDCNAVProductionLines " extends NAVProductionLines
{
    fields
    {
        field(50100; "WMS Consump Created"; Boolean)
        {
            Caption = 'WMS Consump Created';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
