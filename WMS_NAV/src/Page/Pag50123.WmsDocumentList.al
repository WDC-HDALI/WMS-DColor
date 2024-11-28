page 50123 "Wms Document List"
{
    ApplicationArea = All;
    Caption = 'Wms Document List';
    Editable = false;
    PageType = List;
    SourceTable = "WMS Header";
    UsageCategory = Lists;
    CardPageId = "Wms Document";

    layout
    {
        area(content)
        {
            repeater(General)
            {
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

        }
    }
    actions
    {

        area(Reporting)
        {
            action("Print")
            {
                Image = ChangeBatch;
                ApplicationArea = all;
                CaptionML = FRA = 'Synchroniser WMS-BC';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    IntegWmsBc: Report WmsBCManagement;
                begin
                    IntegWmsBc.Run();
                end;
            }
        }

    }
}
