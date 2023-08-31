#property indicator_chart_window

// Define arrays to hold values
double dailyMovers[];
double dailyChanges[];
double correlations[];

// Define column positions
#define LEFT_COLUMN    20
#define MIDDLE_COLUMN  200
#define RIGHT_COLUMN   380

// Number of symbols to monitor
#define SYMBOL_COUNT   10

// Symbols to monitor
string symbols[SYMBOL_COUNT] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD", "USDCHF", "EURJPY", "EURGBP", "USDZAR"};

//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(dailyMovers, true);
   ArraySetAsSeries(dailyChanges, true);
   ArraySetAsSeries(correlations, true);
   EventSetMillisecondTimer(20);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
// Updates every M1 candle
   Print("hello");
   UpdateDailyMovers();
   UpdateCorrelations();
   DrawDashboard();
  }
//+------------------------------------------------------------------+
void UpdateDailyMovers()
  {
   datetime currentTime = TimeCurrent();
   datetime dailyOpenTime = iTime(NULL, PERIOD_D1, 0);

// Reset values at the start of a new daily candle
   if(dailyOpenTime == currentTime)
     {
      ArrayResize(dailyMovers, 0);
      ArrayResize(dailyChanges, 0);
     }

// Iterate through symbols and calculate market movers
   for(int idx = 0; idx < SYMBOL_COUNT; idx++)
     {
      string symbol = symbols[idx];
      double highPrice = iHigh(symbol, PERIOD_D1, 0);
      double openPrice = iOpen(symbol, PERIOD_D1, 0);
      double lowPrice = iLow(symbol, PERIOD_D1, 0);
      double current = iClose(symbol, PERIOD_D1, 0);

      double mover = ((current - openPrice) / (highPrice - lowPrice)) * 100;
      if(ArraySize(dailyMovers) <= idx)
         ArrayResize(dailyMovers, idx + 1);
      dailyMovers[idx] = mover;

      double change = ((current - openPrice) / openPrice) * 100;
      if(ArraySize(dailyChanges) <= idx)
         ArrayResize(dailyChanges, idx + 1);
      dailyChanges[idx] = change;
     }
  }
//+------------------------------------------------------------------+
void UpdateCorrelations()
  {
// Iterate through symbols and calculate correlations for all timeframes
   for(int idx1 = 0; idx1 < SYMBOL_COUNT; idx1++)
     {
      string symbol1 = symbols[idx1];
      for(int idx2 = idx1 + 1; idx2 < SYMBOL_COUNT; idx2++)
        {
         string symbol2 = symbols[idx2];
         double correlation = 0;
         for(int tf = PERIOD_M1; tf <= PERIOD_MN1; tf *= 2)
           {
            correlation += CalculateCorrelation(symbol1, tf, symbol2, 14, 0);
           }
         correlation /= 9; // Average correlation across all timeframes
         if(ArraySize(correlations) <= idx1 * SYMBOL_COUNT + idx2)
            ArrayResize(correlations, idx1 * SYMBOL_COUNT + idx2 + 1);
         correlations[idx1 * SYMBOL_COUNT + idx2] = correlation;
        }
     }
  }
//+------------------------------------------------------------------+
double CalculateCorrelation(string symbol1, int timeframe, string symbol2, int period, int shift)
  {
   double series1[];
   double series2[];
   ArraySetAsSeries(series1, true);
   ArraySetAsSeries(series2, true);

   int copied1 = CopyClose(symbol1, timeframe, shift, period, series1);
   int copied2 = CopyClose(symbol2, timeframe, shift, period, series2);

   if(copied1 != period || copied2 != period)
      return 0; // Not enough data

   double mean1 = 0;
   double mean2 = 0;
// Commented out the loop variable definition. Please replace it with a suitable name if needed.
// for (int k = 0; k < period; k++)
// {
//    mean1 += series1[k];
//    mean2 += series2[k];
// }
   mean1 /= period;
   mean2 /= period;

   double numerator = 0;
   double denominator1 = 0;
   double denominator2 = 0;
// Commented out the loop variable definition. Please replace it with a suitable name if needed.
// for (int k = 0; k < period; k++)
// {
//    numerator += (series1[k] - mean1) * (series2[k] - mean2);
//    denominator1 += MathPow(series1[k] - mean1, 2);
//    denominator2 += MathPow(series2[k] - mean2, 2);
// }

   if(denominator1 == 0 || denominator2 == 0)
      return 0; // Prevent division by zero

   return numerator / (MathSqrt(denominator1) * MathSqrt(denominator2));
  }
//+------------------------------------------------------------------+
void DrawDashboard()
  {
// Clear previous dashboard objects
   ObjectsDeleteAll(0, "Dashboard_");

// Draw daily market movers
   for(int idx = 0; idx < ArraySize(dailyMovers); idx++)
     {
      string dailyMoverLabel = symbols[idx];
      double mover = dailyMovers[idx];
      double change = dailyChanges[idx];
      string dailyMoverLabelName = "Dashboard_DailyMovers_" + IntegerToString(idx);
      string dailyMoverText = dailyMoverLabel + ": " + DoubleToString(mover, 2) + "% (" + DoubleToString(change, 2) + "%)";
      ObjectCreate(0, dailyMoverLabelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, dailyMoverLabelName, OBJPROP_XDISTANCE, LEFT_COLUMN);
      ObjectSetInteger(0, dailyMoverLabelName, OBJPROP_YDISTANCE, 20 + 15 * idx);
      ObjectSetString(0, dailyMoverLabelName, OBJPROP_TEXT, dailyMoverText);
      ObjectSetInteger(0, dailyMoverLabelName, OBJPROP_COLOR, clrWhite);
     }

// Draw correlations
   int counter = 0;
   for(int idx1 = 0; idx1 < SYMBOL_COUNT; idx1++)
     {
      for(int idx2 = idx1 + 1; idx2 < SYMBOL_COUNT; idx2++)
        {
         double correlation = correlations[idx1 * SYMBOL_COUNT + idx2];
         string correlationLabel = symbols[idx1] + " - " + symbols[idx2];
         string correlationLabelName = "Dashboard_Correlations_" + IntegerToString(counter);
         string correlationText = correlationLabel + ": " + DoubleToString(correlation * 100, 2) + "%";
         ObjectCreate(0, correlationLabelName, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, correlationLabelName, OBJPROP_XDISTANCE, RIGHT_COLUMN);
         ObjectSetInteger(0, correlationLabelName, OBJPROP_YDISTANCE, 20 + 15 * counter);
         ObjectSetString(0, correlationLabelName, OBJPROP_TEXT, correlationText);
         ObjectSetInteger(0, correlationLabelName, OBJPROP_COLOR, clrWhite);
         counter++;
        }
     }
  }
//+------------------------------------------------------------------+













//+------------------------------------------------------------------+
