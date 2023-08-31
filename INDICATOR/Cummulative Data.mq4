#property strict

string majorPairs[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD", "EURGBP", "EURJPY", "GBPJPY", "AUDJPY", "EURCHF"};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    double dailyMarketMove = DailyMarketMovers();
    Comment("Daily Market Movers: ", dailyMarketMove, "%\n");

    int pairsCount = ArraySize(majorPairs);
    for(int i = 0; i < pairsCount; i++) {
        if(StringCompare(Symbol(), majorPairs[i]) != 0) { // Using StringCompare instead of direct comparison
            double correlationValue = Correlation(Symbol(), majorPairs[i]);
            Comment("Correlation with ", majorPairs[i], ": ", correlationValue, "%\n");
        }
    }

    double tickVolumeProfileValue = TickVolumeProfile();
    Comment("Tick Volume Profile: ", tickVolumeProfileValue, "\n");

    double cumulativeDeltaValue = CumulativeDelta();
    Comment("Cumulative Delta: ", cumulativeDeltaValue, "\n");

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
double DailyMarketMovers(int shift=1) 
{
    double prevClose = iClose(Symbol(), PERIOD_D1, shift+1);
    double currentClose = iClose(Symbol(), PERIOD_D1, shift);
    return ((currentClose - prevClose) / prevClose) * 100.0;  // added explicit 100.0
}

double Correlation(string symbol1, string symbol2, int period=14) 
{
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;
    double sumY2 = 0;
    for(int i = 0; i < period; i++) 
    {
        double x = iClose(symbol1, PERIOD_D1, i);
        double y = iClose(symbol2, PERIOD_D1, i);
        sumX += x;
        sumY += y;
        sumXY += x*y;
        sumX2 += x*x;
        sumY2 += y*y;
    }
    double n = (double) period;
    double denominator = sqrt(n*sumX2 - sumX*sumX) * sqrt(n*sumY2 - sumY*sumY);
    if (denominator == 0) return 0.0;
    return (n*sumXY - sumX*sumY) / denominator;
}

double TickVolumeProfile(int shift=0) 
{
    return (double) iVolume(Symbol(), PERIOD_D1, shift); // Explicit casting
}

double CumulativeDelta(int bars=100) 
{
    double delta = 0.0;
    for(int i = 0; i < bars; i++) 
    {
        if(iClose(Symbol(), PERIOD_D1, i) > iOpen(Symbol(), PERIOD_D1, i)) 
        {
            delta += (double) iVolume(Symbol(), PERIOD_D1, i);
        } 
        else 
        {
            delta -= (double) iVolume(Symbol(), PERIOD_D1, i);
        }
    }
    return delta;
}

//+------------------------------------------------------------------+
