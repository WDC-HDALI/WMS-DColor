tableextension 50141 WDCSalesInvoiceHeader extends "Sales Invoice Header"
{
    fields
    {
        field(50100; "Update WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50102; "Order Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }


    }
}
