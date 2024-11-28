pageextension 50134 "WMS Sales Return Order Subform" extends "Sales Return Order Subform"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("Update WMS Date"; Rec."Update WMS Date")
            {
                ApplicationArea = all;
            }
            field("Update WMS Time"; Rec."Update WMS Time")
            {
                ApplicationArea = all;
            }
        }

    }

}
