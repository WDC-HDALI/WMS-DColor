pageextension 50143 "Wms Preocessor order" extends "Order Processor Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(Control000121121; "WMS Dashbord")
            {
                ApplicationArea = all;
            }
        }
    }
}
