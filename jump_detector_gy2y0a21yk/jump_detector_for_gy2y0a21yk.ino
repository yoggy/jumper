//
//  jump_detector_for_gy2y0a21yk.ino
//
//  GP2Y0A21YK : http://akizukidenshi.com/catalog/g/gI-02551/
//  センサのV0出力をArduinoのA0ピンに接続
//
int threshold = 400;

int32_t total = 0;
int avg = 0;

void setup() {
  Serial.begin(115200);
  while (!Serial) { /* for leonald, Arduino micro */ }
}

int count = 30;

void loop() {
  total = 0;
  avg = 0;
  for (int i = 0; i < count; ++i) {
    int val = analogRead(A1);  // 距離が近いほど値が大きくなる
    total += val;
  }
  avg = total / count;  
  Serial.println(avg);
  
  // for debug
  if (avg > 400) {
    digitalWrite(13, HIGH);
  }
  else {
    digitalWrite(13, LOW);
  }
}


