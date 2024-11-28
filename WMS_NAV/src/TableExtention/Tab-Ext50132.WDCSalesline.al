tableextension 50132 WDCSalesline extends "Sales Line"
{
    fields
    {

        modify(Quantity)
        {

            trigger OnAfterValidate()
            var
                lSalesHeader: Record "Sales Header";
            begin


                if rec."Document Type" = rec."Document Type"::Order then begin
                    if lSalesHeader.get(rec."Document Type", rec."Document No.") then
                        Rec.validate("Qty to Prepare Wms", Quantity);
                    Rec.Validate("Qty. to Ship", 0);
                end;
            end;
        }
        modify("Qty. to Ship")
        {
            trigger OnAfterValidate()
            var
                lSalesHeader: Record "Sales Header";
                lsalesLines: Record "Sales Line";
                lCustomer: record Customer;
                lCustTaxGroup: record 50012;
                ltext001: Label 'You cannot release an order with any quantity to prepare WMS';
                SubsWedata: Codeunit 50190;
            begin
                If lSalesHeader.get(lSalesHeader."Document Type"::Order, Rec."Document No.") Then Begin
                    if lCustomer.get(lSalesHeader."Sell-to Customer No.") then begin
                        if lCustTaxGroup.Get(lCustomer."Tax Group") Then Begin
                            Case lCustomer."Tax Group" of
                                'FODEC-EXCLUDED':
                                    UpdateTaxLines(lSalesHeader."No.", false, True, False, false, 0);
                                'IRPP1%':
                                    UpdateTaxLines(lSalesHeader."No.", False, true, false, True, lCustTaxGroup."IRPP Percent");
                                'IRPP3%':
                                    UpdateTaxLines(lSalesHeader."No.", False, true, false, True, lCustTaxGroup."IRPP Percent");
                                'LOCAL':
                                    UpdateTaxLines(lSalesHeader."No.", True, True, False, false, 0);
                            end;
                        end
                    end;
                end;
            end;
        }
        field(50100; "Update WMS Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50101; "Update WMS Time"; time)
        {
            DataClassification = ToBeClassified;
            Editable = false;

        }
        field(50102; "Qty to Prepare Wms"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if rec.Quantity - "Quantity Shipped" < "Qty to Prepare Wms" Then
                    if (rec."Document Type" = rec."Document Type"::Order) and (rec.Type = rec.Type::Item) then begin
                        rec.validate("Qty. to Ship", 0);
                        rec.validate("Qty. to Invoice", 0);
                    end;
            end;
        }
        field(50103; "Free sales"; Boolean)
        {
            DataClassification = ToBeClassified;

        }

    }

    Procedure UpdateTaxLines(pDocumentNo: Code[20]; pFodec: Boolean; pStamp: Boolean; pIRPP1: Boolean; pIRPP3: Boolean; pPercent: Decimal)
    Var

        lsalesLines: Record "Sales Line";
        lsalesLinesTax: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        if pIRPP1 then
            UpdateTax(pDocumentNo, '432601', pPercent);
        if pIRPP3 then
            UpdateTax(pDocumentNo, '432602', pPercent);
        if pFodec then
            UpdateTax(pDocumentNo, '436580', SalesSetup."Fodec Percent");
        if pStamp then
            UpdateTax(pDocumentNo, '437100', 0);
    end;

    Procedure UpdateTax(pDocumentNo: Code[20]; pAccountNo: Code[20]; pPercent: Decimal)
    Var
        lsalesLines: Record "Sales Line";
        lsalesLinesTax: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        SubsWedata: Codeunit 50190;
        CUWDC: Codeunit 80;
    begin
        SalesSetup.get;
        lsalesLines.Reset();
        lsalesLines.SetRange("Document No.", pDocumentNo);
        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
        lsalesLines.setrange(Type, lsalesLines.Type::"G/L Account");
        lsalesLines.SetRange("No.", pAccountNo);
        lsalesLines.SetRange("Is Tax Line", true);
        if lsalesLines.FindFirst() then begin
            lsalesLines.Validate("Unit Price", SubsWedata.GetTotShpAmt(pDocumentNo) * pPercent / 100);
            lsalesLines.Modify(TRUE);

        end;
    end;
}
