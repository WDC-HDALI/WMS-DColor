pageextension 50140 "WMS Purchase Orders List" extends "Purchase Order List"
{
    layout
    {
        addafter("Posting Date")
        {
            field("Update WMS"; Rec."Update WMS")
            {
                ApplicationArea = all;
            }

        }

    }

}
