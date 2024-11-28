tableextension 50138 "WDC Purchase Cue" extends "Purchase Cue"
{
    fields
    {
        field(50100; "Prepared Orders WMS"; Integer)
        {
            Caption = 'Prepared Orders WMS';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Update WMS" = filter(true),
                                                 "Document Type" = filter(Order)));
        }

    }
}
