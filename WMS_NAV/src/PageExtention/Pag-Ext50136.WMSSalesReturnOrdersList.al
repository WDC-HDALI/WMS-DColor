pageextension 50136 "WMS Sales Return Orders List" extends "Sales Return Order List"
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
