page 50122 "WMS Lines List"
{
    Caption = 'WMS Lines List';
    PageType = List;
    SourceTable = "WMS LINE";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
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
                field(Unit; Rec.Unit)
                {
                    ApplicationArea = All;
                }




                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field("New Location Code"; Rec."New Location Code")
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

                field("Bc Update Date"; Rec."Bc Update Date")
                {
                    ApplicationArea = All;
                }
                field("Bc Update Time"; Rec."Bc Update Time")
                {
                    ApplicationArea = All;
                }

                field("Integ Bc Failed"; Rec."Integ Bc Failed")
                {
                    ApplicationArea = All;
                }


            }
        }
    }
}
