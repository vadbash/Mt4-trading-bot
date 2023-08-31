// Define indicator property
#property indicator_chart_window

// Define your symbols/pairs
string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD", "USDCHF"};

// Number of bars to calculate correlation
int correlationLength = 50;

double gridStartX = 20;  // x-position of the first square in the heatmap
double gridStartY = 20;  // y-position of the first square in the heatmap
double gridSize = 30;    // size of each square in the heatmap

color GetColorForCorrelation(double value) {
    if (value > 0.8) return Lime;       // Strong positive correlation
    else if (value > 0.5) return Green;
    else if (value > 0.2) return Yellow;
    else if (value > -0.2) return Orange;
    else if (value > -0.5) return Red;
    else if (value > -0.8) return DeepPink;
    else return Magenta;                // Strong negative correlation
}

double CalculateCorrelation(string symbol1, string symbol2, int len) {
    double prices1[];
    double prices2[];
    ArraySetAsSeries(prices1, true);
    ArraySetAsSeries(prices2, true);

    // Load historical data for both symbols
    int count1 = CopyClose(symbol1, 0, 0, len, prices1);
    int count2 = CopyClose(symbol2, 0, 0, len, prices2);

    if(count1 == -1 || count2 == -1) {
        Print("Error loading data");
        return 0.0;
    }

    // Calculate correlation between the two symbols
    double sum1 = 0.0, sum2 = 0.0, sum1Sq = 0.0, sum2Sq = 0.0, pSum = 0.0;
    for(int i = 0; i < len; i++) {
        sum1 += prices1[i];
        sum2 += prices2[i];
        sum1Sq += prices1[i] * prices1[i];
        sum2Sq += prices2[i] * prices2[i];
        pSum += prices1[i] * prices2[i];
    }

    double num = pSum - (sum1 * sum2 / len);
    double den = sqrt((sum1Sq - sum1 * sum1 / len) * (sum2Sq - sum2 * sum2 / len));
    
    if(den == 0) return 0.0;
    return num / den;
}

int OnInit() {
    for (int i = 0; i < ArraySize(symbols); i++) {
        for (int j = 0; j < ArraySize(symbols); j++) {
            if (i != j) {
                double correlation = CalculateCorrelation(symbols[i], symbols[j], correlationLength);
                Print("Correlation between ", symbols[i], " and ", symbols[j], " is: ", correlation);
                
                // Create rectangle (square) to represent correlation
                double x = gridStartX + j * gridSize;
                double y = gridStartY + i * gridSize;
                
                string objectName = "heatmap_" + symbols[i] + "_" + symbols[j];
                ObjectCreate(objectName, OBJ_RECTANGLE_LABEL, 0, Time[0] + x, High[0] + y, Time[0] + x + gridSize, High[0] + y + gridSize);
                
                ObjectSetInteger(0, objectName, OBJPROP_COLOR, GetColorForCorrelation(correlation));
                ObjectSetInteger(0, objectName, OBJPROP_SELECTED, 0);
                ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, 0);
                ObjectSetText(objectName, DoubleToStr(correlation, 2), 8, "Arial", Black);
            }
        }
    }
    return(INIT_SUCCEEDED);
}

int start() {
    return(0);
}
