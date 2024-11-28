pageextension 50130 WarehouseSetup extends "Warehouse Setup"
{
    layout
    {
        addafter("Shipment Posting Policy")
        {
            field("WMS Journal Template Name"; Rec."WMS Journal Template Name")
            {
                ApplicationArea = all;
            }
            field("WMS Journal Batch Name"; Rec."WMS Journal Batch Name")
            {
                ApplicationArea = all;
            }
            field("Email error BC-WMS"; Rec."Email error BC-WMS")
            {
                ApplicationArea = all;
            }
        }

    }

}
