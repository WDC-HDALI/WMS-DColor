page 50121 "WMS List"
{
    Caption = 'WMS List';
    PageType = List;
    SourceTable = "WMS Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(documentBCNo; Rec."Document BC No.")
                {
                    Caption = 'Document BC No.';
                    ApplicationArea = all;
                }
                field(documentBCType; Rec."Document BC Type")
                {
                    Caption = 'Document BC Type';
                    ApplicationArea = all;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                    ApplicationArea = all;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type';
                    ApplicationArea = all;
                }
                field(importID; Rec.ImportID)
                {
                    Caption = 'ImportID';
                    ApplicationArea = all;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                    ApplicationArea = all;
                }
                field(refWMS; Rec."Ref WMS")
                {
                    Caption = 'Ref WMS';
                    ApplicationArea = all;
                }
                field(relationNo; Rec."Relation No.")
                {
                    Caption = 'Relation No.';
                    ApplicationArea = all;
                }
                field(relationType; Rec."Relation Type")
                {
                    Caption = 'Relation Type';
                    ApplicationArea = all;
                }

                field(transferredDocument; Rec."Transferred Document")
                {
                    Caption = 'Transferred Document';
                    ApplicationArea = all;
                }
                field(validatedDocument; Rec."Validated Document")
                {
                    Caption = 'Validated Document';
                    ApplicationArea = all;
                }
            }
        }
    }

}
