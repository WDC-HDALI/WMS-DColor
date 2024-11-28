tableextension 50135 "WDC Sales Cue" extends "Sales Cue"
{
    fields
    {
        field(50100; "Prepared Orders WMS"; Integer)
        {
            Caption = 'Prepared Orders WMS';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Update WMS" = filter(true),
                                                 "Document Type" = filter(Order)));
        }

    }
}
