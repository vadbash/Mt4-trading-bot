#property strict

// Input parameters
input double lotSize = 0.01;

// Global variables
datetime lastTradeTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Drawdown settings if necessary and any initialization steps can be added here.
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Any cleanup steps can be added here.
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (NewDay() && lastTradeTime != Time[0])
     {
      // Buy & Sell at the close of the candlestick
      double closePrice = Close[0];
      
      int buyTicket = OrderSend(Symbol(), OP_BUY, lotSize, closePrice, 3, 0, 0, "BuyOrder", 0, 0, Green);
      if (buyTicket < 0)
        {
         Print("Buy order failed with error: ", GetLastError());
        }
        
      int sellTicket = OrderSend(Symbol(), OP_SELL, lotSize, closePrice, 3, 0, 0, "SellOrder", 0, 0, Red);
      if (sellTicket < 0)
        {
         Print("Sell order failed with error: ", GetLastError());
        }
      
      // Update the last trade time
      lastTradeTime = Time[0];
     }
  }

//+------------------------------------------------------------------+
bool NewDay()
  {
   static datetime lastTime = 0;
   if (Time[0] != lastTime)
     {
      lastTime = Time[0];
      if (TimeDay(Time[0]) != TimeDay(Time[1]))
        {
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+




