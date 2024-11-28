tableextension 50139 "WDC Production Order" extends "Production Order"
{
    //WDC01  17/01/2024  WDC.CHG Add nex field "Model"
    fields
    {
        field(50100; WMS_Decl_Prod; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50101; "Update WMS Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50102; "Update WMS Time"; time)
        {
            DataClassification = ToBeClassified;
            Editable = false;

        }
    }
}