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

void loop() {
  total = 0;
  avg = 0;
  for (int i = 0; i < 10; ++i) {
    int val = analogRead(A0);  // 距離が近いほど値が大きくなる
    total += val;
  }
  avg = total / 10;  
  Serial.println(avg);
}
