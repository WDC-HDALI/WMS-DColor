table 50102 "WMS LINE"
{
    CaptionML = ENU = 'WMS LINE', FRA = 'WMS LINE';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Document No."; Code[20])
        {
            CaptionML = FRA = 'Document No.', ENU = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(2; "Line No."; Integer)
        {
            CaptionML = FRA = 'Ligne No.', ENU = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Item No."; Code[20])
        {
            CaptionML = FRA = 'Article No.', ENU = 'Item No.';
            DataClassification = ToBeClassified;
            TableRelation = Item;
            trigger OnValidate()
            begin
                IF GItem.get("Item No.") then begin
                    Description := Gitem.Description;
                    Unit := Gitem."Base Unit of Measure";
                end
                else begin
                    Description := '';
                    unit := '';
                end;
            end;
        }
        field(4; "Description"; Code[50])
        {
            CaptionML = FRA = 'Description', ENU = 'Description';
            DataClassification = ToBeClassified;
        }
        field(5; "Unit"; Code[10])
        {
            CaptionML = FRA = 'Unité', ENU = 'Unit';
            DataClassification = ToBeClassified;
        }
        field(6; "Location Code"; Code[10])
        {
            CaptionML = FRA = 'Magasin', ENU = 'Location Code';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(7; "Bin Code"; Code[10])
        {
            CaptionML = FRA = 'Emplacement', ENU = 'Bin Code';
            DataClassification = ToBeClassified;
            TableRelation = Bin;
        }
        field(8; "Lot No."; Code[20])
        {
            CaptionML = FRA = 'Lot No.', ENU = 'Lot No.';
            DataClassification = ToBeClassified;

        }
        field(9; "New Location Code"; Code[10])
        {
            CaptionML = FRA = 'Nouveau Magasin', ENU = 'New Location Code';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(10; "New Bin Code"; Code[10])
        {
            CaptionML = FRA = 'Nouveau Emplacement', ENU = 'New Bin Code';
            DataClassification = ToBeClassified;
            TableRelation = Bin;
        }
        field(11; "Quantity"; Decimal)
        {
            CaptionML = FRA = 'Quantité', ENU = 'Quantity';
            DataClassification = ToBeClassified;

        }
        field(12; "Return Motif"; Code[10])
        {
            CaptionML = FRA = 'Motif Retour', ENU = 'Return Motif';
            DataClassification = ToBeClassified;
            TableRelation = "Return Reason";
        }
        field(13; "ImportID"; Integer)
        {
            CaptionML = FRA = 'Ref WMS', ENU = 'Ref WMS';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14; "Document BC No."; Code[20])
        {
            CaptionML = FRA = 'Document BC No.', ENU = 'Document BC No.';
            DataClassification = ToBeClassified;
        }
        field(15; "Line No. BC"; Integer)
        {
            CaptionML = FRA = 'No. ligne BC', ENU = 'Line No. BC';
            DataClassification = ToBeClassified;
        }
        field(16; "Bc Update Date"; Date)
        {
            CaptionML = FRA = 'Date mise à jour Bc', ENU = '"Bc Update Date"';
            DataClassification = ToBeClassified;
        }
        field(17; "Bc Update Time"; Time)
        {
            CaptionML = FRA = 'Temp mise à jour Bc', ENU = 'Bc Update Time';
            DataClassification = ToBeClassified;
        }
        field(18; MouvementLineId; Integer)
        {
            CaptionML = FRA = 'Mouvement Line Id', ENU = 'Mouvement Line Id';
            DataClassification = ToBeClassified;

        }

        field(19; "Integ Bc Failed"; Boolean)
        {
            CaptionML = ENU = 'Integ Bc Failed';
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        GItem: record Item;
        Goutput: record "Production order";

}