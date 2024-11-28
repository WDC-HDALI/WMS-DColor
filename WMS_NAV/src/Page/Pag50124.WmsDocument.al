page 50124 "Wms Document"
{
    Caption = 'Wms Document';
    PageType = Card;
    SourceTable = "WMS Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Document BC No."; Rec."Document BC No.")
                {
                    ApplicationArea = All;
                }
                field("Document BC Type"; Rec."Document BC Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field(ImportID; Rec.ImportID)
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Ref WMS"; Rec."Ref WMS")
                {
                    ApplicationArea = All;
                }
                field("Relation No."; Rec."Relation No.")
                {
                    ApplicationArea = All;
                }
                field("Relation Type"; Rec."Relation Type")
                {
                    ApplicationArea = All;
                }

                field("Transferred Document"; Rec."Transferred Document")
                {
                    ApplicationArea = All;
                }
                field("Validated Document"; Rec."Validated Document")
                {
                    ApplicationArea = All;
                }
            }
            part("Wms Line"; "Wms Line")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = FIELD("Document No.");
                UpdatePropagation = Both;

            }
        }
    }
}
