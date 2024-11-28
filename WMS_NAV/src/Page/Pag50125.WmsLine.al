page 50125 "Wms Line"
{
    Caption = 'Wms Line';
    PageType = ListPart;
    SourceTable = "WMS LINE";


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Document BC No."; Rec."Document BC No.")
                {
                    ApplicationArea = All;
                }
                field("Line No. BC"; Rec."Line No. BC")
                {
                    ApplicationArea = All;
                }


                field("New Location Code"; Rec."New Location Code")
                {
                    ApplicationArea = All;
                }

                field("Return Motif"; Rec."Return Motif")
                {
                    ApplicationArea = All;
                }
                field(Unit; Rec.Unit)
                {
                    ApplicationArea = All;
                }
                field("Integ Bc Failed"; rec."Integ Bc Failed")
                {
                    ApplicationArea = All;
                }
                field("Bc Update Date"; Rec."Bc Update Date")
                {
                    ApplicationArea = All;
                }
                field("Bc Update Time"; Rec."Bc Update Time")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
