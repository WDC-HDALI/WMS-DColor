pageextension 50133 "WMS Sales Orders List" extends "Sales Order List"
{
    layout
    {
        addafter("Posting Date")
        {
            field("Update WMS"; Rec."Update WMS")
            {
                ApplicationArea = all;
            }
            field("Order Group"; Rec."Order Group")
            {
                ApplicationArea = all;
            }

        }


    }


    actions
    {

        addbefore(Post)
        {
            action("Grouping")
            {

                caption = 'Grouping Selected orders';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;
                Image = Compress;
                trigger OnAction()
                var
                    lNoSeriesManagement: Codeunit NoSeriesManagement;
                    lSalesSetup: Record "Sales & Receivables Setup";
                    lSalesHeader: Record "Sales Header";
                    lNextGroupNo: code[20];
                    ltext001: Label 'Order N° %1 is already grouped in the group %2';
                    ltext002: label 'Do you want to group the seleced orders?';
                begin
                    if not Dialog.Confirm(lText002) then
                        exit;
                    lSalesSetup.get;
                    lSalesSetup.TestField("Order Group Nos.");
                    lNextGroupNo := lNoSeriesManagement.GetNextNo(lSalesSetup."Order Group Nos.", WorkDate(), true);

                    lSalesHeader.Reset();
                    CurrPage.SetSelectionFilter(lSalesheader);
                    if lSalesHeader.FindFirst() Then
                        repeat
                            if lSalesHeader."Order Group" <> '' Then
                                Error(ltext001, lSalesHeader."No.", lSalesHeader."Order Group");
                            lSalesHeader."Order Group" := lNextGroupNo;
                            lSalesHeader.Modify();
                        until lSalesHeader.Next() = 0;
                    CurrPage.Update();
                    Message('Selected orders are groped by the number: %1', lNextGroupNo);
                end;
            }
        }
        //>>WDC.SH

    }


}
