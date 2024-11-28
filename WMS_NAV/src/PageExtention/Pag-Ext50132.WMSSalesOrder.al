pageextension 50132 "WMS Sales Order" extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("Update WMS"; rec."Update WMS")
            {
                ApplicationArea = all;
            }

        }

    }


    actions
    {
        modify(ApplyTaxes)
        {
            Visible = false;
        }
        addbefore(Post)
        {

            action("AppTax")
            {
                caption = 'Apply Ship tax';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;
                Image = TaxPayment;
                trigger OnAction()
                var
                    lsalesLines: Record "Sales Line";
                    lCustomer: record Customer;
                    lCustTaxGroup: record 50012;
                    WDCSubscriber: Codeunit 50190;
                    ltext001: Label 'You cannot apply tax on order with any quantity to prepare WMS';
                begin
                    If Rec."Document Type" = Rec."Document Type"::Order Then Begin
                        lsalesLines.Reset();
                        lsalesLines.SetRange("Document No.", Rec."No.");
                        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
                        lsalesLines.setrange(Type, lsalesLines.Type::Item);
                        lsalesLines.SetFilter("Qty to Prepare Wms", '<>%1', 0);
                        if lsalesLines.IsEmpty then
                            Error(ltext001);
                        if lCustomer.get(Rec."Sell-to Customer No.") then begin
                            if lCustTaxGroup.Get(lCustomer."Tax Group") Then Begin
                                Case lCustomer."Tax Group" of
                                    'FODEC-EXCLUDED':
                                        WDCSubscriber.InsertTaxSalesLines(Rec."No.", false, True, False, false, 0);
                                    'IRPP1%':
                                        WDCSubscriber.InsertTaxSalesLines(Rec."No.", False, true, false, True, lCustTaxGroup."IRPP Percent");
                                    'IRPP3%':
                                        WDCSubscriber.InsertTaxSalesLines(Rec."No.", False, true, false, True, lCustTaxGroup."IRPP Percent");
                                    'LOCAL':
                                        WDCSubscriber.InsertTaxSalesLines(Rec."No.", True, True, False, false, 0);
                                end;
                            end
                        end;
                    end;

                end;
            }
        }
    }

}
