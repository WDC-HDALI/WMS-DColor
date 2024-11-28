pageextension 50131 "WMS Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        modify("Qty. to Ship")
        {
            Editable = false;
        }
        modify("Qty. to Invoice")
        {
            Editable = false;
        }

        addafter("Shipment Date")
        {
            field("Update WMS Date"; Rec."Update WMS Date")
            {
                ApplicationArea = all;
            }
            field("Update WMS Time"; Rec."Update WMS Time")
            {
                ApplicationArea = all;
            }
        }
        addafter(Quantity)
        {
            field("Qty to Prepare"; Rec."Qty to Prepare Wms")
            {
                ApplicationArea = all;
            }
            field("Free sales"; Rec."Free sales")
            {
                ApplicationArea = all;
                Editable = Rec.Type = Rec.type::Item;
                trigger OnValidate()
                var
                    lText001: label 'You cannot set free a lines with quantity to ship great than 0';
                begin
                    if rec."Document Type" = rec."Document Type"::Order then begin
                        if rec."Qty. to Ship" <> 0 Then
                            error(lText001);
                    end;

                end;
            }
        }

    }

}
