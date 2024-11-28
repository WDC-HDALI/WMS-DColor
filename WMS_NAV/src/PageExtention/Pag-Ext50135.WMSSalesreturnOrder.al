pageextension 50135 "WMS Sales return Order" extends "Sales Return Order"
{
    layout
    {
        addafter(Status)
        {
            field("Update WMS"; Rec."Update WMS")
            {
                ApplicationArea = all;
            }

        }

    }

}
