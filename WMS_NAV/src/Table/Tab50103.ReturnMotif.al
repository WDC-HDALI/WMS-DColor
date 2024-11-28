table 50103 "RETURN MOTIF"
{
    CaptionML = ENU = 'Return Motif', FRA = 'Motif retour';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Code"; Code[20])
        {
            CaptionML = FRA = 'Code', ENU = 'Code';
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(2; Description; Code[50])
        {
            CaptionML = FRA = 'Description', ENU = 'Description';
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }

    }


}