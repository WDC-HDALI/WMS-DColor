pageextension 50138 "WMS Purchase return Order" extends "Purchase Return Order"
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
