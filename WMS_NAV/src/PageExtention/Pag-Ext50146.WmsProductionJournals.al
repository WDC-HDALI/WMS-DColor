pageextension 50146 WmsProductionJournals extends 5510
{

    Actions
    {
        addlast(Processing)
        {
            action("Create Consumption")
            {
                Image = ConsumptionJournal;
                PromotedIsBig = true;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()

                var
                    lCreateConsumption: Page "Create Consumption";
                begin

                    Clear(lCreateConsumption);
                    CreateWmsConsumptionLine(Rec."Order No.", rec."Order Date")

                end;
            }
        }
    }
    procedure CreateWmsConsumptionLine(pProductionOrderNo: Code[20]; pDateFilter: date)
    Var
        lItemJnlLine: Record 83;
        ModeleFeuille: text;
        NomFeuille: Text;
        lItem: Record item;
        lPostDocNo: Code[20];
        WhseSetup: Record "Warehouse Setup";
        WMSHeader: record "WMS Header";
        NoSeriesManagement: Codeunit 311;
        lReservationEntry: Record 337;
        lIndex: Integer;
        lNAVProductionHeader: Record NAVProductionHeader;
        lNAVProductionLines: Record NAVProductionLines;
        Window: Dialog;
    begin
        Window.open('Processing..');
        WhseSetup.get;
        ModeleFeuille := 'PROD. ORDE';
        NomFeuille := copystr(UserId, 1, 10);

        lItemJnlLine.Reset();
        lItemJnlLine.SetFilter("Journal Template Name", ModeleFeuille);
        lItemJnlLine.SetFilter("Journal Batch Name", NomFeuille);
        if lItemJnlLine.FindFirst() Then
            repeat
                //     Message('1');
                lNAVProductionLines.Reset();
                lNAVProductionLines.SetRange(IDDALJE, lItemJnlLine."Document No.");
                //lNAVProductionLines.SetRange(rec_date, CREATEDATETIME(lItemJnlLine."Posting Date", 0T));
                lNAVProductionLines.SetRange(KODIRECEPTURES, lItemJnlLine."Item No.");
                if lNAVProductionLines.FindFirst() then Begin
                    lItemJnlLine.Validate(Quantity, lNAVProductionLines.SASIARECEPTURES);
                    lItemJnlLine.Modify(true);
                    //              Message('2');
                end;
            UNTIL lItemJnlLine.Next() = 0;
        Message('%1 Consumption Journal lines created', lItemJnlLine.Count);
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
