import controlP5.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;
import java.util.*;

ControlP5 cp5;
Serial serial;
LineChart line_chart;
int threshold;
int now_val;

PFont font_normal = createFont("Impact", 36);
OscP5 oscP5;
NetAddress myRemoteLocation;


void setup() {  
  size(600, 600);
  cp5 = new ControlP5(this);
  cp5.addSlider("threshold").setPosition(20, 20).setSize(200, 15).setRange(0, 1023).setValue(500);
  serial = new Serial(this, "/dev/ttyACM0", 115200);
  line_chart = new LineChart(5000);

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
}

void readSerial() {
  while (serial.available () > 0) {
    String l = serial.readStringUntil(10);
    if (l == null) continue;
    l = trim(l);
    int val = parseInt(l);
    line_chart.add(val);
    now_val = val;
  }
}

void draw() {
  readSerial();

  background(0, 0, 0);
  line_chart.draw();

  stroke(0, 255, 0);
  line(0, threshold / 1024.0 * height, width, threshold / 1024.0 * height);

  log("sensor_value", ""+ now_val);
  log("threshold", ""+ threshold);

  check_jump();

  // debug info
  fill(0, 255, 0);
  textFont(font_normal);  
  text(String.format("val=%d, threshold=%d", now_val, threshold), 20, height - 30);
}

void stop() {
  serial.stop();
}

int jump_guard_counter = 0;
void check_jump() {
  if (jump_guard_counter == 0) {
    if (line_chart.max_val(10) > threshold) {
      fire_jump();
      jump_guard_counter = 10;
    }
  }
  if (jump_guard_counter > 0) jump_guard_counter --;
}

void fire_jump() {
  log("fire_jump", "");
  OscMessage myMessage = new OscMessage("/jump");
  oscP5.send(myMessage, myRemoteLocation);
}

class LineChart {
  Vector vals = new Vector();
  int max_size = 1024;

  LineChart(int size) {
    max_size = size;
  }

  int get(int idx) {
    return ((Integer)vals.get(idx)).intValue();
  }

  void add(int val) {
    vals.add(val);
    if (vals.size() > max_size) {
      vals.remove(0);
      vals.trimToSize();
    }
  }

  void draw() {
    noFill();
    stroke(0, 255, 0);
    float step_x = width / (float)(max_size);
    float step_y =  (height / 1024.0);
    for (int i = 0; i < vals.size() - 1; ++i) {    
      float x0 = (i  ) * step_x;
      float x1 = (i+1) * step_x;
      float y0 = ((Integer)vals.get(i  )).intValue() * step_y;
      float y1 = ((Integer)vals.get(i+1)).intValue() * step_y;
      line(x0, y0, x1, y1);
    }
  }

  int max_val(int n) {
    int max_val = 0;
    int st = vals.size() - n;
    if (st < 0) st = 0;
    int et = vals.size() - 1;
    for (int i = st; i <= et; ++i) {
      int v = (Integer)vals.get(i);
      if (v > max_val) max_val = v;
    }
    return max_val;
  }
}

