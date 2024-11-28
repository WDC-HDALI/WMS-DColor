pageextension 50148 "WMS Released Production Orders" extends "Released Production Orders"
{
    layout
    {
        addafter("Due Date")
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
