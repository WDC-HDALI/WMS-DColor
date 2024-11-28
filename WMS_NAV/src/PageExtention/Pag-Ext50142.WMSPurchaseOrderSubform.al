pageextension 50142 "WMS Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addafter("Allow Invoice Disc.")
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
