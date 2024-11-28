pageextension 50139 "WMS Purch Return Order Subform" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Reserved Quantity")
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
