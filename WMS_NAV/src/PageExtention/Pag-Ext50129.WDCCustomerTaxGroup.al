pageextension 50129 "WDC Customer Tax Group" extends "Customer Tax Group List"
{
    layout
    {
        addafter(Description)
        {
            field(Percent; Rec."IRPP Percent")
            {
                ApplicationArea = All;
            }
        }
    }
}