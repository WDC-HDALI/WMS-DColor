page 50130 "Create Consumption"
{
    CaptionML = ENU = 'Create Consumption', FRA = 'Create Consumption';
    PageType = StandardDialog;
    SourceTable = NAVProductionHeader;


    layout
    {
        area(Content)
        {
            group(Control)
            {
                ShowCaption = false;

                field("Production Order No."; ProductionOrderNo)
                {
                    TableRelation = "Production Order"."No.";
                }
                field(DocNoSacada; DocNoSacada)
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        lNavProdHeader: Record NAVProductionHeader;
                        NAVProdDocList: page "NAV Production Documents List";
                    begin
                        CLEAR(NAVProdDocList);
                        lNavProdHeader.RESET;
                        lNavProdHeader.SETRANGE("WMS Consump Created", false);
                        NAVProdDocList.SETTABLEVIEW(lNavProdHeader);
                        NAVProdDocList.SETRECORD(lNavProdHeader);
                        IF NAVProdDocList.RUNMODAL = ACTION::OK THEN BEGIN
                            NAVProdDocList.GETRECORD(lNavProdHeader);
                            DocNoSacada := lNavProdHeader.NRDOK;
                        END;
                    end;
                }
                field("Date Filter"; DateFilter)
                {

                }
            }

        }
    }
    trigger OnQueryClosePage(Closeaction: Action): Boolean
    var
        myInt: Integer;
    begin
        if Closeaction = action::OK then begin
            if (DateFilter = 0D) or (ProductionOrderNo = '') then
                Error('Production Order No. and Date Filter should have values');
            CreateWmsConsumptionLine(ProductionOrderNo, DateFilter);
        end;

    end;

    procedure CreateWmsConsumptionLine(pProductionOrderNo: Code[20]; pDateFilter: date)
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lPostDocNo: Code[20];
        WhseSetup: Record "Warehouse Setup";
        WMSHeader: record "WMS Header";
        NoSeriesManagement: Codeunit 396;
        lReservationEntry: Record 337;
        lIndex: Integer;
        lNAVProductionHeader: Record NAVProductionHeader;
        lNAVProductionLines: Record NAVProductionLines;
        Window: Dialog;
    begin
        Window.open('Processing..');
        WhseSetup.get;
        ModeleFeuille := 'SCADA_CONS';
        NomFeuille := 'Default';
        lNAVProductionHeader.Reset();
        lNAVProductionHeader.SETRANGE(DATEDOK, CREATEDATETIME(pDateFilter, 0T), CREATEDATETIME(pDateFilter, 235959T));
        IF DocNoSacada <> '' THEN
            lNAVProductionHeader.SetRange(NRDOK, DocNoSacada);
        //lNAVProductionHeader.SetRange(Consumption, false);
        if lNAVProductionHeader.FINDSET THEN
            repeat
                lNAVProductionLines.Reset();
                lNAVProductionLines.SetRange(IDDALJE, lNAVProductionHeader.NRDOK);
                if lNAVProductionLines.FindFirst() then
                    repeat
                        IF lItem.Get(lNAVProductionLines.KODIRECEPTURES) THEN begin
                            lIndex := InitIndex(ModeleFeuille, NomFeuille);
                            lItemJnlLine.INIT;
                            lItemJnlLine.VALIDATE("Journal Template Name", ModeleFeuille);
                            lItemJnlLine.VALIDATE("Journal Batch Name", NomFeuille);
                            lItemJnlLine."Line No." := lIndex;
                            lItemJnlLine."Posting Date" := pDateFilter;
                            lItemJnlLine."Entry Type" := lItemJnlLine."Entry Type"::Consumption;
                            lItemJnlLine."Order Type" := lItemJnlLine."Order Type"::Production;
                            lItemJnlLine.Validate("Order No.", pProductionOrderNo);
                            lItemJnlLine.VALIDATE("Item No.", lNAVProductionLines.KODIRECEPTURES);
                            lItemJnlLine.VALIDATE(Quantity, lNAVProductionLines.SASIARECEPTURES);
                            lItemJnlLine.VALIDATE("Unit of Measure Code", lItem."Base Unit of Measure");
                            lItemJnlLine.VALIDATE("Location Code", lNAVProductionLines.MAGAZINARECEPTURES);
                            lItemJnlLine.Insert(true);
                        end;
                    UNTIL lNAVProductionLines.Next() = 0;
            UNTIL lNAVProductionHeader.Next() = 0;
        Message('%1 Consumption Journal lines created', lNAVProductionHeader.Count);
        lNAVProductionHeader.ModifyAll("WMS Consump Created", true);
        Window.close;
    End;

    procedure InitIndex(pModeleFeuille: Code[10]; pNomFeuille: Code[10]) Index: Integer;
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
    end;

    var
        ProductionOrderNo: code[20];
        DateFilter: Date;
        DocNoSacada: code[20];
}

