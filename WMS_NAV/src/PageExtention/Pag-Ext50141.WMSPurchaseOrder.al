pageextension 50141 "WMS Purchase Order" extends "Purchase Order"
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
