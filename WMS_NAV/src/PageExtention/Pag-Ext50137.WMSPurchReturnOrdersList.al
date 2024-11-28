pageextension 50137 "WMS Purch Return Orders List" extends "Purchase Return Order List"
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
