tableextension 50131 WDCSalesHeader extends "Sales Header"
{
    fields
    {
        field(50100; "Update WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50101; "Selected to group"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Order Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        //         field(50101; "Validated Document"; Boolean)
        // {
        //     CaptionML = FRA = 'Document transféré', ENU = 'Transferred Document';
        //     Editable = false;
        //     FieldClass = FlowField;
        //     CalcFormula = exist("Sales Line" where("Document No." = field("No."),
        //                                                        "Document Type" = field("Document Type"),
        //                                                        ));
        //}

    }
}
