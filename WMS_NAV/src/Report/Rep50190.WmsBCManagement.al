report 50190 WmsBCManagement
{
    ApplicationArea = All;
    Caption = 'WmsNavmanagement';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem(WMSHeader; "WMS Header")
        {
            RequestFilterFields = "Document No.";
            trigger OnAfterGetRecord()
            var
                lDialog: Dialog;
                lText001: Label 'Traitement encours..';
            begin
                SalesPayablesSetup.GET;
                warehouseSetup.Get();
                lDialog.Open(lText001);
                Integ_In_Nav(WMSHeader."Document No.");
                lDialog.Close();
            end;
        }
    }

    procedure Integ_In_Nav(pWMSDocNo: Code[20])
    Var
        lWMSHeader: Record "WMS Header";
        lDocType: enum "Sales Document Type";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        lSalesHeader: Record "Sales Header";
        lPurchaseHeader: Record "Purchase Header";
    begin
        lWMSHeader.Reset();
        lWMSHeader.SetFilter("Document No.", pWMSDocNo);
        if lWMSHeader.FindFirst() then
            repeat
                case lWMSHeader."Entry Type" of
                    lWMSHeader."Entry Type"::Purchase:
                        begin
                            if (lWMSHeader."Relation Type" = lWMSHeader."Relation Type"::"Vendor") AND (lWMSHeader."Relation No." <> '') then Begin
                                if lPurchaseHeader.get(lPurchaseHeader."Document Type"::Order, lWMSHeader."Document BC No.") then begin
                                    ReleasePurchaseDocument.Reopen(lPurchaseHeader);
                                    UpdatePurchaseOrder(lWMSHeader."Document No.", lWMSHeader."Document BC No.");
                                    ReleasePurchaseDocument.ReleasePurchaseHeader(lPurchaseHeader, false);
                                end;
                            End;
                        end;
                    lWMSHeader."Entry Type"::Sale:
                        begin
                            if (lWMSHeader."Relation Type" = lWMSHeader."Relation Type"::"Customer") AND (lWMSHeader."Relation No." = 'C00038') then
                                CreateSalesDocument(lWMSHeader."Document No.", lDocType::Order)
                            else
                                if (lWMSHeader."Relation Type" = lWMSHeader."Relation Type"::"Customer") AND (lWMSHeader."Relation No." <> '') then begin
                                    if lSalesHeader.get(lSalesHeader."Document Type"::Order, lWMSHeader."Document BC No.") then begin
                                        if lSalesHeader."Shipment Date" < WorkDate() then
                                            lSalesHeader."Shipment Date" := WorkDate();
                                        lSalesHeader.Status := lSalesHeader.Status::Open;
                                        lSalesHeader.Modify();
                                        // ReleaseSalesDocument.Reopen(lSalesHeader);
                                        //Message(Format(lSalesHeader."Shipment Date"));
                                        UpdateSalesOrder(lWMSHeader."Document No.", lWMSHeader."Document BC No.");
                                        InsertTaxOrder(lWMSHeader."Document BC No.");
                                        lSalesHeader.Status := lSalesHeader.Status::Released;
                                        lSalesHeader.Modify();
                                        //ReleaseSalesDocument.ReleaseSalesHeader(lSalesHeader, false);
                                    end;
                                end;
                        end;
                    lWMSHeader."Entry Type"::"Negative Adjust":
                        begin
                            if (lWMSHeader."Relation Type" = lWMSHeader."Relation Type"::" ") AND (lWMSHeader."Relation No." = '') then
                                CreateAdjustment(lWMSHeader."Document No.")
                            else
                                CreatePurchaseReturnOrder(lWMSHeader."Document No.");
                        end;
                    lWMSHeader."Entry Type"::"Positive Adjust":
                        begin
                            if (lWMSHeader."Relation Type" = lWMSHeader."Relation Type"::" ") AND (lWMSHeader."Relation No." = '') then
                                CreateAdjustment(lWMSHeader."Document No.")
                            else
                                CreateSalesDocument(lWMSHeader."Document No.", lDocType::"Return Order");
                        end;
                    lWMSHeader."Entry Type"::Transfert:
                        CreateTransfertLine(lWMSHeader."Document No.");
                    //  lWMSHeader."Entry Type"::Consumption:
                    /// CreateConsumption(lWMSHeader."Document No.");
                    lWMSHeader."Entry Type"::Output:
                        //      PostWmsOutput_without_Consumption(lWMSHeader."Document No.");
                        CreateWmsProductionLine(lWMSHeader."Document No.");
                //CreateWmsProduction_SCADA_Consumption(lWMSHeader."Document No.");

                end;
            until lWMSHeader.Next = 0;
    end;

    procedure UpdatePurchaseOrder(pDocumentNo: Code[20]; pBCDocumentNo: Code[20])
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
        lPurchaseLine: Record "Purchase Line";
        lPurchaseHeader: Record "Purchase Header";
    begin
        lWMSLines.Reset();
        lWMSLines.SetRange("Document No.", pDocumentNo);
        lWMSLines.setfilter("Bc Update Date", '%1', 0D);
        if lWMSLines.FindFirst() then
            repeat
                if lPurchaseLine.Get(lPurchaseLine."Document Type"::Order, pBCDocumentNo, lWMSLines."Line No. BC") Then begin
                    If lPurchaseLine.Type = lPurchaseLine.type::Item Then begin
                        if lWMSLines.Quantity > 0 Then begin
                            lPurchaseLine.Validate("Qty. to Receive", lWMSLines.Quantity);
                            lPurchaseLine."Update WMS Date" := WorkDate();
                            lPurchaseLine."Update WMS Time" := time;
                            if lPurchaseLine.Modify() then begin
                                lWMSLines."Bc Update Date" := WorkDate();
                                lWMSLines."Bc Update Time" := Time;
                                if lPurchaseHeader.get(lPurchaseHeader."Document Type"::Order, pBCDocumentNo) then begin
                                    lPurchaseHeader."Update WMS" := true;
                                    lPurchaseHeader.Modify();
                                end;
                            end else
                                lWMSLines."Integ Bc Failed" := true;
                            lWMSLines.Modify();
                        end;
                    end;

                end;
            until lWMSLines.Next() = 0;
    end;

    procedure CreatePurchaseReturnOrder(pDocumentNo: Code[20])
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
        lPurchaseHeader: Record "Purchase Header";
        lPurchaseHeader1: Record "Purchase Header";
        lPurchaseLine: Record "Purchase line";
        lLineNo: Integer;
    begin
        lLineNo := 0;
        If lWMSHeader.Get(pDocumentNo) Then begin
            lPurchaseHeader1.reset;
            lPurchaseHeader1.SetRange("Vendor Order No.", lWMSHeader."Ref WMS");
            lPurchaseHeader1.SetRange("Document Type", lPurchaseHeader."Document Type"::"Return Order");
            if Not lPurchaseHeader1.FindFirst() Then begin
                lPurchaseHeader.Init();
                lPurchaseHeader."Document Type" := lPurchaseHeader."Document Type"::"Return Order";
                lPurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasePayablesSetup."Return Order Nos.", 0D, TRUE);
                lPurchaseHeader.Validate("Pay-to Vendor No.", lWMSHeader."Relation No.");
                lPurchaseHeader.Validate("Buy-from Vendor No.", lWMSHeader."Relation No.");
                lPurchaseHeader.Validate("Posting Date", WORKDATE);
                lPurchaseHeader."Vendor Order No." := lWMSHeader."Ref WMS";
                lPurchaseHeader."Update WMS" := true;
                if lPurchaseHeader.INSERT(true) Then begin
                    lWMSLines.Reset();
                    lWMSLines.SetRange("Document No.", pDocumentNo);
                    if lWMSLines.FindFirst() then
                        repeat
                            lPurchaseLine."Document Type" := lPurchaseHeader."Document Type";
                            lPurchaseLine."Document No." := lPurchaseHeader."No.";
                            lPurchaseLine."Line No." := lLineNo + 10000;
                            lPurchaseLine.Type := lPurchaseLine.Type::Item;
                            lPurchaseLine.Validate("No.", lWMSLines."Item No.");
                            lPurchaseLine.validate("Location Code", lWMSLines."Location Code");
                            lPurchaseLine.Validate(Quantity, lWMSLines.Quantity);
                            lPurchaseLine."Update WMS Date" := WorkDate();
                            lPurchaseLine."Update WMS Time" := time;
                            If lPurchaseLine.INSERT(true) Then Begin
                                lWMSLines."Bc Update Date" := WorkDate();
                                lWMSLines."Bc Update Time" := Time;
                            end else
                                lWMSLines."Integ Bc Failed" := true;
                            lWMSLines.Modify();
                        until lWMSLines.Next() = 0;
                end;
            end;
        end;
    End;

    procedure CreateSalesDocument(pDocumentNo: Code[20]; pDocType: enum "Sales Document Type")
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
        lSalesHeader: Record "Sales Header";
        lSalesHeader1: Record "Sales Header";
        lSalesLine: Record "sales line";
        lLineNo: Integer;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        lLineNo := 0;
        If lWMSHeader.Get(pDocumentNo) Then begin
            lWMSHeader.CalcFields("Transferred Document");
            if Not WMSHeader."Transferred Document" Then begin
                lSalesHeader1.Reset();
                lSalesHeader1.SetRange("External Document No.", pDocumentNo);
                lSalesHeader1.SetRange("Document Type", pDocType);
                If Not lSalesHeader1.FindFirst() then begin
                    lSalesHeader.Init();
                    lSalesHeader."Document Type" := pDocType;
                    if pDocType = pDocType::"Return Order" Then
                        lSalesHeader."No." := NoSeriesManagement.GetNextNo(SalesPayablesSetup."Return Order Nos.", 0D, TRUE)
                    else
                        if pDocType = pDocType::Order Then
                            lSalesHeader."No." := NoSeriesManagement.GetNextNo(SalesPayablesSetup."Order Nos.", 0D, TRUE);
                    if lSalesHeader.INSERT(true) Then begin
                        lSalesHeader.Validate("Sell-to Customer No.", lWMSHeader."Relation No.");
                        lSalesHeader.Validate("Bill-to Customer No.", lWMSHeader."Relation No.");
                        lSalesHeader.Validate("Posting Date", WORKDATE);
                        lSalesHeader."External Document No." := pDocumentNo;
                        lSalesHeader."Update WMS" := true;
                        if lSalesHeader.Modify(true) Then begin
                            lWMSLines.Reset();
                            lWMSLines.SetRange("Document No.", pDocumentNo);
                            lWMSLines.SetRange("Bc Update Date", 0D);
                            if lWMSLines.FindFirst() then
                                repeat
                                    lLineNo += 10000;
                                    lSalesLine."Document Type" := pDocType;
                                    lSalesLine."Document No." := lSalesHeader."No.";
                                    lSalesLine."Line No." := lLineNo;
                                    lSalesLine.Insert(true);
                                    lSalesLine.Type := lSalesLine.Type::Item;
                                    lSalesLine.Validate("No.", lWMSLines."Item No.");
                                    lSalesLine.validate("Location Code", lWMSLines."Location Code");
                                    lSalesLine.Validate(Quantity, lWMSLines.Quantity);
                                    lsalesLine."Update WMS Date" := WorkDate();
                                    lsalesLine."Update WMS Time" := time;
                                    If lSalesLine.Modify(true) then Begin
                                        lWMSLines."Document BC No." := lSalesLine."Document No.";
                                        lWMSLines."Line No. BC" := lSalesLine."Line No.";
                                        lWMSLines."Bc Update Date" := WorkDate();
                                        lWMSLines."Bc Update Time" := Time;
                                    end else
                                        lWMSLines."Integ Bc Failed" := true;
                                    lWMSLines.Modify();
                                until lWMSLines.Next() = 0;
                            if ReleaseSalesDoc.ReleaseSalesHeader(lSalesHeader, false) Then;
                        end;
                    end;
                end;
            end;
        end;
    end;

    procedure UpdateSalesOrder(pDocumentNo: Code[20]; pBCDocumentNo: Code[20])
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
        lsalesLine: Record "Sales Line";
        lsalesHeader: Record "Sales Header";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        lWMSLines.Reset();
        lWMSLines.SetRange("Document No.", pDocumentNo);
        lWMSLines.setfilter("Bc Update Date", '%1', 0D);
        if lWMSLines.FindFirst() then
            repeat
                if lsalesLine.Get(lsalesLine."Document Type"::Order, pBCDocumentNo, lWMSLines."Line No. BC") Then begin
                    if lsalesLine.Type = lsalesLine.type::Item then begin
                        if (lWMSLines.Quantity > 0) and (lsalesLine.Quantity - lsalesLine."Quantity Shipped" >= lWMSLines.Quantity) Then begin
                            if lWMSLines.Quantity <= lsalesLine.Quantity then
                                lsalesLine.Validate("Qty. to Ship", lWMSLines.Quantity)
                            else
                                lsalesLine.Validate("Qty. to Ship", lsalesLine.Quantity);
                            lsalesLine."Qty to Prepare Wms" := 0;
                            lsalesLine."Update WMS Date" := WorkDate();
                            lsalesLine."Update WMS Time" := time;
                            lWMSLines."Bc Update Date" := WorkDate();
                            lWMSLines."Bc Update Time" := time;
                            lWMSLines.Modify();
                            if lsalesLine.Modify() then begin
                                if lsalesHeader.get(lsalesHeader."Document Type"::Order, pBCDocumentNo) Then begin
                                    lsalesHeader."Update WMS" := true;
                                    lsalesHeader.Modify();
                                end;
                            end;
                        end;
                    end;
                end;
            until lWMSLines.Next() = 0;
    end;

    procedure InsertTaxOrder(pDocumentNo: Code[20])
    var
        lsalesHeader: record "Sales Header";
        lsalesLines: Record "Sales Line";
        lCustomer: record Customer;
        lCustTaxGroup: record 50012;
        lSubscribersBC_WMS: Codeunit "Subscribers BC_WMS";

        ltext001: Label 'You cannot release an order with any quantity to prepare WMS or to ship';
    begin
        if lsalesHeader.get(lsalesHeader."Document Type"::Order, pDocumentNo) Then begin
            If lSalesHeader."Document Type" = lSalesHeader."Document Type"::Order Then Begin
                if lCustomer.get(lSalesHeader."Sell-to Customer No.") then begin
                    if lCustTaxGroup.Get(lCustomer."Tax Group") Then Begin
                        Case lCustomer."Tax Group" of
                            'FODEC-EXCLUDED':
                                lSubscribersBC_WMS.InsertTaxSalesLines(lSalesHeader."No.", false, True, False, false, 0);
                            'IRPP1%':
                                lSubscribersBC_WMS.InsertTaxSalesLines(lSalesHeader."No.", False, true, false, True, lCustTaxGroup."IRPP Percent");
                            'IRPP3%':
                                lSubscribersBC_WMS.InsertTaxSalesLines(lSalesHeader."No.", False, true, false, True, lCustTaxGroup."IRPP Percent");
                            'LOCAL':
                                lSubscribersBC_WMS.InsertTaxSalesLines(lSalesHeader."No.", True, True, False, false, 0);
                        end;
                    end
                end;

            end;
        end;
    end;

    procedure CreateAdjustment(pDocumentNo: Code[20])
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
    begin
        lWMSLines.Reset();
        lWMSLines.SetRange("Document No.", pDocumentNo);
        if lWMSLines.FindFirst() then
            repeat
                CreateWmsAdjustLine(lWMSLines."Document No.", lWMSLines."Line No.");
            until lWMSLines.Next() = 0;
    end;

    procedure CreateTransfertLine(pDocumentNo: Code[20])
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
    begin
        lWMSLines.Reset();
        lWMSLines.SetRange("Document No.", pDocumentNo);
        lWMSLines.setfilter("Bc Update Date", '%1', 0D);
        if lWMSLines.FindFirst() then
            repeat
                PostTransfertLine(lWMSLines."Document No.", lWMSLines."Line No.");
            until lWMSLines.Next() = 0;
    end;

    procedure CreateConsumption(pDocumentNo: Code[20])
    var
        lWMSHeader: Record "WMS Header";
        lWMSLines: record "WMS LINE";
    begin
        lWMSLines.Reset();
        lWMSLines.SetRange("Document No.", pDocumentNo);
        lWMSLines.setfilter("Bc Update Date", '%1', 0D);
        if lWMSLines.FindFirst() then
            repeat
                CreateWmsConsumptionLine(lWMSLines."Document No.", lWMSLines."Line No.");
            until lWMSLines.Next() = 0;
    end;


    procedure CreateWmsAdjustLine(pDocumentNo: Code[20]; pLineNo: Integer)
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lWMSLines: record "WMS LINE";
        lPostDocNo: Code[20];
        WhseSetup: Record "Warehouse Setup";
        WMSHeader: record "WMS Header";
        NoSeriesManagement: Codeunit 396;

    begin
        WhseSetup.get;
        ModeleFeuille := 'WMS ITEM';
        NomFeuille := 'Default';
        Init_ItemJNLLine(ModeleFeuille, NomFeuille);
        InitIndex(ModeleFeuille, NomFeuille);
        if WMSHeader.Get(pDocumentNo) then
            if lWMSLines.Get(pDocumentNo, pLineNo) Then begin
                if (lWMSLines."Document BC No." <> '') AND (lWMSLines."Line No. BC" <> 0) then begin
                    lItem.Get(lWMSLines."Item No.");
                    lItemJnlLine.INIT;
                    lItemJnlLine.VALIDATE("Journal Template Name", ModeleFeuille);
                    lItemJnlLine.VALIDATE("Journal Batch Name", NomFeuille);
                    lItemJnlLine."Line No." := Index;
                    lItemJnlLine."Posting Date" := WMSHeader."Posting Date";
                    Case WMSHeader."Entry Type" of
                        WMSHeader."Entry Type"::"Negative Adjust":
                            lItemJnlLine."Entry Type" := lItemJnlLine."Entry Type"::"Negative Adjmt.";
                        WMSHeader."Entry Type"::"Positive Adjust":
                            lItemJnlLine."Entry Type" := lItemJnlLine."Entry Type"::"Positive Adjmt.";
                    End;
                    lItemJnlLine."Document No." := lWMSLines."Document No.";
                    If lItemJnlLine.Insert(true) then Begin
                        lItemJnlLine.VALIDATE("Item No.", lWMSLines."Item No.");
                        lItemJnlLine.VALIDATE(Quantity, lWMSLines.Quantity);
                        lItemJnlLine.VALIDATE("Unit of Measure Code", lItem."Base Unit of Measure");
                        lItemJnlLine.VALIDATE("Location Code", lWMSLines."Location Code");
                        If lItemJnlLine.Modify(true) then Begin
                            ItemJnlPostBatch.Run(lItemJnlLine);
                            lWMSLines."Bc Update Date" := WorkDate();
                            lWMSLines."Bc Update Time" := Time;
                        end else
                            lWMSLines."Integ Bc Failed" := true;
                        lWMSLines.Modify();
                    end;
                End;
            end;
    End;

    procedure PostTransfertLine(pDocumentNo: Code[20]; pLineNo: Integer)
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lWMSLines: record "WMS LINE";
        lPostDocNo: Code[20];
        WhseSetup: Record "Warehouse Setup";
        WMSHeader: record "WMS Header";
        NoSeriesManagement: Codeunit 396;
        lReservationEntry: Record 337;
    begin
        WhseSetup.get;
        ModeleFeuille := 'WMS TRANSF';
        NomFeuille := 'Default';
        Init_ItemJNLLine(ModeleFeuille, NomFeuille);
        if WMSHeader.Get(pDocumentNo) then
            if lWMSLines.Get(pDocumentNo, pLineNo) Then begin
                lItem.Get(lWMSLines."Item No.");
                InitIndex(ModeleFeuille, NomFeuille);
                lItemJnlLine.INIT;
                lItemJnlLine.VALIDATE("Journal Template Name", ModeleFeuille);
                lItemJnlLine.VALIDATE("Journal Batch Name", NomFeuille);
                lItemJnlLine."Line No." := Index;
                lItemJnlLine."Posting Date" := WMSHeader."Posting Date";
                lItemJnlLine.Validate("Entry Type", lItemJnlLine."Entry Type"::Transfer);
                lItemJnlLine."Document No." := lWMSLines."Document No.";
                lItemJnlLine.VALIDATE("Item No.", lWMSLines."Item No.");
                lItemJnlLine.VALIDATE(Quantity, lWMSLines.Quantity);
                lItemJnlLine.VALIDATE("Unit of Measure Code", lItem."Base Unit of Measure");
                lItemJnlLine.VALIDATE("Location Code", lWMSLines."Location Code");
                lItemJnlLine.Validate("New Location Code", lWMSLines."New Location Code");
                lItemJnlLine.validate("New Bin Code", lWMSLines."New Bin Code");
                If lItemJnlLine.Insert(true) then Begin
                    ItemJnlPostBatch.Run(lItemJnlLine);
                    lWMSLines."Bc Update Date" := WorkDate();
                    lWMSLines."Bc Update Time" := Time;
                end else
                    lWMSLines."Integ Bc Failed" := true;
                lWMSLines.Modify();

            end;
    End;

    procedure CreateWmsConsumptionLine(pDocumentNo: Code[20]; pLineNo: Integer)
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lWMSLines: record "WMS LINE";
        lPostDocNo: Code[20];
        WhseSetup: Record "Warehouse Setup";
        WMSHeader: record "WMS Header";
        NoSeriesManagement: Codeunit 396;
        lReservationEntry: Record 337;
    begin
        WhseSetup.get;
        ModeleFeuille := 'WMS CONSUM';
        NomFeuille := 'Default';
        InitIndex(ModeleFeuille, NomFeuille);
        if WMSHeader.Get(pDocumentNo) then
            if lWMSLines.Get(pDocumentNo, pLineNo) Then begin
                lItem.Get(lWMSLines."Item No.");
                lItemJnlLine.INIT;
                lItemJnlLine.VALIDATE("Journal Template Name", ModeleFeuille);
                lItemJnlLine.VALIDATE("Journal Batch Name", NomFeuille);
                lItemJnlLine."Line No." := Index;
                lItemJnlLine."Posting Date" := WMSHeader."Posting Date";
                lItemJnlLine."Entry Type" := lItemJnlLine."Entry Type"::Consumption;
                lItemJnlLine."Document No." := lWMSLines."Document No.";
                lItemJnlLine.VALIDATE("Order Line No.", lWMSLines."Line No. BC");
                lItemJnlLine.VALIDATE("Item No.", lWMSLines."Item No.");
                lItemJnlLine.VALIDATE(Quantity, lWMSLines.Quantity);
                lItemJnlLine.VALIDATE("Unit of Measure Code", lItem."Base Unit of Measure");
                lItemJnlLine.VALIDATE("Location Code", lWMSLines."Location Code");
                If lItemJnlLine.Insert(true) then Begin
                    lWMSLines."Bc Update Date" := WorkDate();
                    lWMSLines."Bc Update Time" := Time;
                end else
                    lWMSLines."Integ Bc Failed" := true;
                lWMSLines.Modify();

            end;
    End;

    procedure CreateWmsProductionLine(pDocumentNo: Code[20])
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lWMSLines: record "WMS LINE";
        lPostDocNo: Code[20];
        WhseSetup: Record "Warehouse Setup";
        lWMSHeader: record "WMS Header";
        NoSeriesManagement: Codeunit 396;
        lReservationEntry: Record 337;
        lProdOrderLine: record "Prod. Order Line";

    begin
        WhseSetup.get;
        ModeleFeuille := 'WMS OUTPUT';
        NomFeuille := 'Default';

        if lWMSHeader.Get(pDocumentNo) then;
        lWMSLines.Reset();
        lWMSLines.SetRange("Document No.", pDocumentNo);
        lWMSLines.SetFilter("Line No. BC", '<>%1', 0);
        lWMSLines.SetFilter("Document BC No.", '<>%1', '');
        lWMSLines.setfilter("Bc Update Date", '%1', 0D);
        If lWMSLines.FindFirst() Then
            repeat
                InitIndex(ModeleFeuille, NomFeuille);
                lProdOrderLine.Reset();
                lProdOrderLine.SetRange(Status, lProdOrderLine.Status::Released);
                lProdOrderLine.SetRange("Prod. Order No.", lWMSLines."Document BC No.");
                lProdOrderLine.SetRange("Line No.", lWMSLines."Line No. BC");
                if lProdOrderLine.FindFirst() then Begin
                    lItem.Get(lProdOrderLine."Item No.");
                    lItemJnlLine.INIT;
                    lItemJnlLine.VALIDATE("Journal Template Name", ModeleFeuille);
                    lItemJnlLine.VALIDATE("Journal Batch Name", NomFeuille);
                    lItemJnlLine."Line No." := Index;
                    lItemJnlLine.VALIDATE("Posting Date", WMSHeader."Posting Date");
                    lItemJnlLine."Entry Type" := lItemJnlLine."Entry Type"::Output;
                    lItemJnlLine."Order Type" := lItemJnlLine."Order Type"::Production;
                    lItemJnlLine."Document No." := lWMSLines."Document BC No.";
                    lItemJnlLine."Order No." := lWMSLines."Document BC No.";
                    lItemJnlLine."Source Code" := 'PRODORDER';
                    lItemJnlLine.VALIDATE(Type, lItemJnlLine.Type::"Work Center");
                    If lItemJnlLine.Insert(true) then begin
                        lItemJnlLine.VALIDATE("Order Line No.", lWMSLines."Line No. BC");
                        lItemJnlLine.VALIDATE("Item No.", lProdOrderLine."Item No.");
                        lItemJnlLine.VALIDATE(Quantity, lWMSLines.Quantity);
                        lItemJnlLine.VALIDATE("Output Quantity", lWMSLines.Quantity);
                        lItemJnlLine.VALIDATE("Unit of Measure Code", lItem."Base Unit of Measure");
                        lItemJnlLine.VALIDATE("Location Code", lWMSLines."New Location Code");
                        If lItemJnlLine.Modify(true) then begin
                            ItemJnlPostBatch.Run(lItemJnlLine);
                            lWMSLines."Bc Update Date" := WorkDate();
                            lWMSLines."Bc Update Time" := Time;
                        end else begin
                            lWMSLines."Integ Bc Failed" := true;
                        end;
                        lWMSLines.Modify();
                    end;
                End;
                CreateWms_SCADA_Consumption(lWMSLines."Document BC No.", lWMSLines."Line No. BC");
            until lWMSLines.Next() = 0;
    end;

    //<<WMS_SCADAé
    procedure CreateWms_SCADA_Consumption(pDocumentNo: Code[20]; PLineNo: Integer)
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lWMSLines: record "WMS LINE";
        WhseSetup: Record "Warehouse Setup";
        lProdOrderLine: record "Prod. Order Line";
        ProductionOrder: Record "Production Order";
        ProductionJrnlMgt: Codeunit "Production Journal Mgt";
        lNAVProductionLines: Record NAVProductionLines;
    begin
        WhseSetup.get;
        ModeleFeuille := 'WMS OUTPUT';
        NomFeuille := 'Default';

        InitIndex(ModeleFeuille, NomFeuille);
        if ProductionOrder.Get(ProductionOrder.Status::Released, pDocumentNo) Then BEGIN
            lProdOrderLine.Reset();
            lProdOrderLine.SetRange(Status, lProdOrderLine.Status::Released);
            lProdOrderLine.SetRange("Prod. Order No.", pDocumentNo);
            lProdOrderLine.SetRange("Line No.", PLineNo);
            if lProdOrderLine.FindFirst() then Begin
                ProductionOrder.WMS_Decl_Prod := true;
                ProductionOrder.Modify();
                ProductionJrnlMgt.Handling(ProductionOrder, lProdOrderLine."Line No.");
                ProductionOrder.WMS_Decl_Prod := false;
                ProductionOrder.Modify();
                lItem.Get(lProdOrderLine."Item No.");

                lItemJnlLine.Reset();
                lItemJnlLine.SetRange("Journal Template Name", ModeleFeuille);
                lItemJnlLine.SetRange("Journal Batch Name", NomFeuille);
                lItemJnlLine.SetRange("Document No.", ProductionOrder."No.");
                if lItemJnlLine.FindSet() then
                    repeat
                        if lItemJnlLine."Entry Type" = lItemJnlLine."Entry Type"::Consumption then begin
                            lNAVProductionLines.Reset();
                            lNAVProductionLines.SetRange(IDDALJE, lItemJnlLine."Document No.");
                            lNAVProductionLines.SetRange(KODIRECEPTURES, lItemJnlLine."Item No.");
                            lNAVProductionLines.SetRange("WMS Consump Created", false);
                            if lNAVProductionLines.FindFirst() then Begin
                                lItemJnlLine.Validate(Quantity, lNAVProductionLines.SASIARECEPTURES);
                                lItemJnlLine.Modify(true);
                                lNAVProductionLines."WMS Consump Created" := true;
                                lNAVProductionLines.Modify();
                            end;
                        end;
                    until lItemJnlLine.Next() = 0;
                ItemJnlPostBatch.Run(lItemJnlLine);
            end;

        end;

    end;
    // //<<WMS SCADA
    procedure InitIndex(pModeleFeuille: Code[10];
        pNomFeuille: Code[10])
    var
        ModeleFeuille: text;
        NomFeuille: Text;
        lItemJournalLine: Record 83;
        lResvEntries: Record 337;
    begin
        lItemJournalLine.Reset();
        lItemJournalLine.SetRange("Journal Template Name", pModeleFeuille);
        lItemJournalLine.SetRange("Journal Batch Name", pNomFeuille);
        if lItemJournalLine.FindLast() then
            Index := lItemJournalLine."Line No." + 10000
        else
            Index := 10000;

        lResvEntries.Reset();
        IF lResvEntries.FINDLAST THEN
            IndexReserv := lResvEntries."Entry No." + 1
        ELSE
            IndexReserv := 1;
    end;

    procedure Init_ItemJNLLine(pModeleFeuille: Code[10]; pNomFeuille: Code[10])
    var
        lItemJnlLine: Record 83;
    begin
        lItemJnlLine.Reset();
        lItemJnlLine.SetFilter("Journal Template Name", pModeleFeuille);
        lItemJnlLine.SetFilter("Journal Batch Name", pNomFeuille);
        lItemJnlLine.DeleteAll();
    end;

    var
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        IndexReserv: Integer;
        Index: Integer;
        warehouseSetup: record "Warehouse Setup";
        NoSeriesManagement: Codeunit 396;
        SalesPayablesSetup: Record 311;
        PurchasePayablesSetup: Record 312;
}

