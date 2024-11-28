codeunit 50190 "Subscribers BC_WMS"
{
    //Email Error JobQue Entries Report 50190
    [EventSubscriber(ObjectType::Table, DATABASE::"Job Queue Log Entry", 'OnAfterInsertEvent', '', FALSE, FALSE)]
    local procedure OnAfterInsertJobQueue(VAR Rec: Record "Job Queue Log Entry")
    Var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        WhseSetup: Record "Warehouse Setup";
        lTextBody: Text;
    begin

        lTextBody := StrSubstNo('La sychronisation est eronée ce jour %1', Rec."End Date/Time");
        WhseSetup.Get;
        If (rec."Object ID to Run" = 50190) and (rec.Status = rec.Status::Error) then begin
            EmailMessage.Create(WhseSetup."Email error BC-WMS", 'Erreur Synchronisation BC-WMS', 'La sychronisation est eronée ce jour');
            Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
        end;

    end;


    procedure Quantities_Controls(pDocNo: Code[20]): Boolean
    var
        lsalesLines: Record "Sales Line";
    begin
        lsalesLines.Reset();
        lsalesLines.SetRange("Document No.", pDocNo);
        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
        lsalesLines.setrange(Type, lsalesLines.Type::Item);
        if lsalesLines.FindFirst() then
            repeat
                if (lsalesLines."Qty to Prepare Wms" <> 0) or (lsalesLines."Qty. to Ship" <> 0) then
                    Exit(true)
            until lsalesLines.Next() = 0;
        exit(false);
    end;

    Procedure InsertTaxSalesLines(pDocumentNo: Code[20]; pFodec: Boolean; pStamp: Boolean; pIRPP1: Boolean; pIRPP3: Boolean; pPercent: Decimal)
    Var
        lsalesLines: Record "Sales Line";
        lsalesLinesTax: Record "Sales Line";
    begin
        SalesSetup.Get();

        lsalesLines.Reset();
        lsalesLines.SetRange("Document No.", pDocumentNo);
        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
        lsalesLines.setrange(Type, lsalesLines.Type::"G/L Account");
        lsalesLines.SetRange("Is Tax Line", true);
        lsalesLines.Deleteall();

        if pIRPP1 then
            InsertTax(pDocumentNo, '432601', pPercent);
        if pIRPP3 then
            InsertTax(pDocumentNo, '432602', pPercent);
        if pFodec then
            InsertTax(pDocumentNo, '436580', SalesSetup."Fodec Percent");
        if pStamp then
            InsertTax(pDocumentNo, '437100', 0);
    end;

    Procedure InsertTax(pDocumentNo: Code[20]; pAccountNo: Code[20]; pPercent: Decimal)
    Var
        lsalesLines: Record "Sales Line";
        lsalesLinesTax: Record "Sales Line";
    begin
        SalesSetup.get;
        lsalesLinesTax.Init();
        lsalesLinesTax."Document Type" := lsalesLinesTax."Document Type"::Order;
        lsalesLinesTax."Document No." := pDocumentNo;
        lsalesLinesTax."Line No." := GetNextLine(pDocumentNo);
        lsalesLinesTax.Type := lsalesLinesTax.Type::"G/L Account";
        lsalesLinesTax.Validate("No.", pAccountNo);
        lsalesLinesTax.validate(Quantity, 1);
        lsalesLinesTax.Validate("Location Code", 'EPF');
        lsalesLinesTax."Qty to Prepare Wms" := 0;
        if (pAccountNo <> '437100') and (pAccountNo <> '') then begin
            lsalesLinesTax.Validate("Unit Price", GetTotShpAmt(pDocumentNo) * pPercent / 100);
            if pAccountNo = '432601' then
                lsalesLinesTax.Validate("Is IRPP 1%", true)
            else if pAccountNo = '432602' then
                lsalesLinesTax.Validate("Is IRPP 3%", true)
            else if pAccountNo = '436580' then
                lsalesLinesTax.Validate(IsFodexTax, true)
        end else if (pAccountNo = '437100') then begin
            lsalesLinesTax.Validate("Unit Price", SalesSetup."Stamp Amount");
            lsalesLinesTax.IsTimberTax := true;
        end;
        lsalesLinesTax."Is Tax Line" := true;
        lsalesLinesTax.Insert(true);

    end;

    Procedure GetNextLine(pDocumentNo: Code[20]): Integer
    Var
        lsalesLines: Record "Sales Line";
    begin
        lsalesLines.Reset();
        lsalesLines.SetRange("Document No.", pDocumentNo);
        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
        If lsalesLines.FindLast() then
            exit(lsalesLines."Line No." + 10000)
        else
            exit(10000)
    end;

    procedure GetTotShpAmt(pDocumentNo: Code[20]): Decimal
    var
        lsalesLines: Record "Sales Line";
        lTotalTTC: Decimal;
    begin
        lsalesLines.Reset();
        lsalesLines.SetRange("Document No.", pDocumentNo);
        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
        lsalesLines.setrange(Type, lsalesLines.Type::Item);
        lsalesLines.setfilter("Qty. to Ship", '<>%1', 0);
        if lsalesLines.FindFirst() then
            repeat
                lTotalTTC += lsalesLines.amount * lsalesLines."Qty. to Ship" / lsalesLines.Quantity;
            until lsalesLines.next = 0;
        exit(lTotalTTC);
    end;

    ///**********************************>>Apply Tax

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'ApplyTaxes', FALSE, FALSE)]
    local procedure ApplyTaxes(var Rec: Record "Sales Header")
    begin
        rec.CalculateAmountInclVat();
        error(FOrmat(rec."Amount Including VAT"));
    end;

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Sales-Post", 'OnAfterCheckSalesDoc', '', FALSE, FALSE)]
    local procedure OnAfterCheckSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean)
    var
        lsalesLines: Record "Sales Line";
        lTotalTTC: Decimal;
        ltextError: Label 'You cannot validate this order without quantity to ship for the line Item';
        QtyToshipExist: Boolean;

    begin
        If Not ExistItemQtyToShip(SalesHeader."No.") Then
            Error(ltextError);
    end;

    procedure ExistItemQtyToShip(pDocumentNo: Code[20]): Boolean
    var
        lsalesLines: Record "Sales Line";
        lTotalTTC: Decimal;
        QtyToshipExist: Boolean;
    begin
        lsalesLines.Reset();
        lsalesLines.SetRange("Document No.", pDocumentNo);
        lsalesLines.setrange("Document Type", lsalesLines."Document Type"::Order);
        lsalesLines.setrange(Type, lsalesLines.Type::Item);
        if lsalesLines.FindFirst() then Begin
            repeat
                if lsalesLines."Qty. to Ship" <> 0 THEN
                    Exit(True);
            until lsalesLines.Next() = 0;
            Exit(false);
        End Else
            exit(True);
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";


}

