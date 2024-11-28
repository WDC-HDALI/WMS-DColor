pageextension 50147 WmsSalesSetup extends "Sales & Receivables Setup"
{
    layout
    {
        addlast("Number Series")
        {
            field("Order Group Nos."; Rec."Order Group Nos.")
            {
                ApplicationArea = all;
            }

        }
        addafter("Default Customer No.")
        {
            group("Sales Tax")
            {

                field("Stamp Amount"; rec."Stamp Amount")
                {
                    ApplicationArea = All;
                }
                field("Fodec Percent"; Rec."Fodec Percent")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
