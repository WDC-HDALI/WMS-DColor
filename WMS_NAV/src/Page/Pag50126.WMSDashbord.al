page 50126 "WMS Dashbord"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";
    Permissions = tabledata "Sales Cue" = rm;

    layout
    {
        area(content)
        {
            cuegroup("For Release")
            {
                Caption = 'WMS';
                field("Prepared Orders WMS"; rec."Prepared Orders WMS")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Order List";
                }
            }
        }
    }
    var


}

