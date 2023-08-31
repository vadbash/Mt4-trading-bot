

string accessToken = "bee2a5b68c7f4f54b56f45a18206cc06";  // Replace with your API key
int timeout = 5000;  // 5 seconds timeout

void OnStart() {
    if (Get12Data() == -1) {
        Print("Error fetching data from 12data.");
    }
}

int Get12Data() {
    char result[4096]; // Initialized with a size
    string headers = "Content-Type: application/x-www-form-urlencoded\r\n\r\n"; // Extra \r\n at the end
    string requestUrl = "https://api.twelvedata.com/time_series?symbol=AAPL&interval=1h&apikey=" + accessToken;

    int res = WebRequest(
        "GET", 
        requestUrl, 
        headers, 
        timeout, 
        result
    );

    if(res == -1) {
        Print("WebRequest failed. Error: ", GetLastError());
        return(-1);
    }

    string data = CharArrayToString(result, res); // Use res to only process the bytes received
    Print(data);

    return(0);
}

string CharArrayToString(char &array[], int size) {
    string resultString = "";
    for (int i = 0; i < size; i++) {
        resultString += CharToStr(array[i]);
    }
    return resultString;
}
