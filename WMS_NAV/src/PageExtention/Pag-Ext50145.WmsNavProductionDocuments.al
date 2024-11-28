pageextension 50145 WmsNavProductionDocuments extends "NAV Production Documents List"
{
    layout
    {
        addlast(General)
        {
            field(Consumption; Rec."WMS Consump Created")
            {
                ApplicationArea = all;
            }

        }

    }
    Actions
    {
        addlast(Processing)
        {
            action("Create Consumption")
            {
                Image = ConsumptionJournal;
                trigger OnAction()

                var
                    lCreateConsumption: Page "Create Consumption";
                begin

                    Clear(lCreateConsumption);
                    lCreateConsumption.RunModal;

                end;
            }
        }
    }


}
