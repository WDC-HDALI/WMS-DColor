table 50101 "WMS Header"
{
    CaptionML = ENU = 'WMS Header', FRA = 'WMS Entête';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Document No."; Code[20])
        {
            CaptionML = FRA = 'Document No.', ENU = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(2; "Entry Type"; Option)
        {
            CaptionML = FRA = 'Entry Type', ENU = 'Type entrée';
            DataClassification = ToBeClassified;
            OptionMembers = "Purchase","Sale","Positive Adjust","Negative Adjust","Transfert","Consumption","Output";
            OptionCaptionML = FRA = 'Achat,Vente,Ajust Positive,Ajust Négative,Transfert,Consommation,Production', ENU = 'Purchase,Sale,Positive Adjust,Negative Adjust,Transfert,Consumption,Output';
        }
        field(3; "Posting Date"; Date)
        {
            CaptionML = FRA = 'Date comptabilisation', ENU = 'Posting Date';
            DataClassification = ToBeClassified;
        }
        field(4; "Document BC Type"; Option)
        {
            CaptionML = FRA = 'Type document BC ', ENU = 'Document BC Type';
            DataClassification = ToBeClassified;
            OptionMembers = "Purchase Order","Sales Order","Production Order","Transfert order";
            OptionCaptionML = FRA = 'Commande Achat,Commande Vente,Ordre de fabrication,Ordre de transfert', ENU = 'Purchase Order,Sales Order,Production Order,Ordre de transfert';
        }
        field(5; "Document BC No."; Code[20])
        {
            CaptionML = FRA = 'Document BC No.', ENU = 'Document BC No.';
            DataClassification = ToBeClassified;
            Trigger OnValidate()
            begin
                Clear(PurchaseOrder);
                IF PurchaseOrder.get(PurchaseOrder."Document Type"::Order, "Document BC No.") THEN begin
                    "Relation Type" := "Relation Type"::Vendor;
                    "Relation No." := PurchaseOrder."Buy-from Vendor No.";
                end
                else begin
                    Clear(SalesOrder);
                    IF SalesOrder.get(SalesOrder."Document Type"::Order, "Document BC No.") THEN begin
                        "Relation Type" := "Relation Type"::Customer;
                        "Relation No." := SalesOrder."Sell-to Customer No.";
                    end
                    else begin
                        "Relation Type" := "Relation Type"::" ";
                        "Relation No." := '';
                    end;
                end;
            end;
        }
        field(6; "Relation Type"; Option)
        {
            CaptionML = FRA = 'Type relation', ENU = 'Relation type';
            OptionMembers = " ","Customer","Vendor";
            OptionCaptionML = FRA = ' ,Client,Fournisseur', ENU = ' ,Customer,Vendor';
        }
        field(7; "Relation No."; Code[20])
        {
            CaptionML = FRA = 'Relation No.', ENU = 'Relation No.';
            DataClassification = ToBeClassified;
        }
        field(8; "Transferred Document"; Boolean)
        {
            CaptionML = FRA = 'Document transféré', ENU = 'Transferred Document';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("WMS LINE" where("Document No." = field("Document No."),
                                                               "Bc Update Date" = filter(<> '')));
        }
        field(9; "Validated Document"; Boolean)
        {
            CaptionML = FRA = 'Document Validé', ENU = 'Validated Document';
            DataClassification = ToBeClassified;
        }
        field(10; "Ref WMS"; Code[20])
        {
            CaptionML = FRA = 'Ref WMS', ENU = 'Ref WMS';
            DataClassification = ToBeClassified;
        }
        field(11; "ImportID"; Integer)
        {
            CaptionML = FRA = 'Ref WMS', ENU = 'Ref WMS';
            Editable = false;
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }

    }
    var
        PurchaseOrder: Record "Purchase Header";
        SalesOrder: Record "Sales Header";

}