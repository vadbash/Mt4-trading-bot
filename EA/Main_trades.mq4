#property strict

// EA Parameters
input double lotSize = 0.1;

// Dashboard parameters
int start_x = 20;
int start_y = 20;
color textColor = Yellow;
string fontType = "Arial";
int fontSize = 10;

//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code here
    CreateDashboard();
    return(INIT_SUCCEEDED);
}

void CreateDashboard()
{
    int y_offset = 20;

    // Display elements of the dashboard
    ObjectCreate("LabelAiPosSize", OBJ_LABEL, 0, 0, 0);
    ObjectSet("LabelAiPosSize", OBJPROP_XDISTANCE, start_x);
    ObjectSet("LabelAiPosSize", OBJPROP_YDISTANCE, start_y);
    ObjectSetText("LabelAiPosSize", "Ai Position Size %Value: [PLACEHOLDER]", fontSize, fontType, textColor);

    ObjectCreate("LabelAiTP", OBJ_LABEL, 0, 0, 0);
    ObjectSet("LabelAiTP", OBJPROP_XDISTANCE, start_x);
    ObjectSet("LabelAiTP", OBJPROP_YDISTANCE, start_y + y_offset);
    ObjectSetText("LabelAiTP", "Ai Take Profit Total: [PLACEHOLDER]", fontSize, fontType, textColor);

    //... Continue for other elements ...

    // Create the Close All Trades button
    ObjectCreate("btnCloseAll", OBJ_BUTTON, 0, Time[0], Close[0]);
    ObjectSet("btnCloseAll", OBJPROP_XDISTANCE, start_x);
    ObjectSet("btnCloseAll", OBJPROP_YDISTANCE, start_y + 8 * y_offset);
    ObjectSet("btnCloseAll", OBJPROP_XSIZE, 120);
    ObjectSet("btnCloseAll", OBJPROP_YSIZE, 25);
    ObjectSetText("btnCloseAll", "Close All Trades", fontSize, fontType, Red);
}

//+------------------------------------------------------------------+
void OnTick()
{
    if (Time[0] != iTime(Symbol(), Period(), 0)) return;

    if (Period() >= PERIOD_D1) return;

    double currentClose = iClose(Symbol(), Period(), 0);
    double previousClose = iClose(Symbol(), Period(), 1);

    if (currentClose > previousClose)
    {
        CloseAllSells();
        if (OrderSend(Symbol(), OP_BUY, lotSize, Ask, 2, 0, 0, "Momentum Buy", 0, 0, clrGreen) < 0)
            Print("OrderSend failed with error: ", GetLastError());
    }
    else if (currentClose < previousClose)
    {
        CloseAllBuys();
        if (OrderSend(Symbol(), OP_SELL, lotSize, Bid, 2, 0, 0, "Momentum Sell", 0, 0, clrRed) < 0)
            Print("OrderSend failed with error: ", GetLastError());
    }

    UpdateDashboard();
}

void UpdateDashboard()
{
    // Update dashboard elements
    // Example:
    ObjectSetText("LabelAiPosSize", "Ai Position Size %Value: [UPDATE_VALUE_HERE]", fontSize, fontType, textColor);
}

//+------------------------------------------------------------------+
void CloseAll()
{
    CloseAllBuys();
    CloseAllSells();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        if(sparam == "btnCloseAll")
        {
            CloseAll();
        }
    }
}

//+------------------------------------------------------------------+
void CloseAllBuys()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderType() == OP_BUY)
        {
            if(!OrderClose(OrderTicket(), OrderLots(), Bid, 2, clrWhite))
            {
                Print("Failed to close buy order. Error:", GetLastError());
            }
        }
    }
}

void CloseAllSells()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderType() == OP_SELL)
        {
            if(!OrderClose(OrderTicket(), OrderLots(), Ask, 2, clrWhite))
            {
                Print("Failed to close sell order. Error:", GetLastError());
            }
        }
    }
}
//+------------------------------------------------------------------+
