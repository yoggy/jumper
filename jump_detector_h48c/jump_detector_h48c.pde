import controlP5.*;
import oscP5.*;
import netP5.*;

float threshold = 1.0f;
ControlP5 cp5;
OscP5 oscP5;
NetAddress myRemoteLocation = new NetAddress("127.0.0.1", 12001);

H48CSensor sensor;
int jump_guard_counter;

void setup() {
  size(300, 300);

  cp5 = new ControlP5(this);
  cp5.addSlider("threshold").setPosition(20, 20).setSize(200, 15).setRange(0.0, 5.0 );

  oscP5 = new OscP5(this, 12000);

  sensor = new H48CSensor(this);
  if (sensor.open("COM3") == false) {
    println("sensor.open() failed...");
    exit();
  }
}

void draw() {
  sensor.recv();
  Vector diff_history = sensor.diff_history();

  background(0, 0, 0);
  sensor.draw_chart(0, 0, width, height, 5.0);

  line(0, threshold * height / 5.0, width, threshold * height / 5.0);

  check_jump();

  if (jump_guard_counter > 0) {
    fill(255, 255, 0);
    rect(0, 0, 100, 100);
  }
}

void check_jump() {
  if (jump_guard_counter == 0) {
    if (sensor.diff(10) > threshold) {
      fire_jump();
      jump_guard_counter = 10;
    }
  }
  if (jump_guard_counter > 0) jump_guard_counter --;
}

void fire_jump() {
  OscMessage myMessage = new OscMessage("/jump");
  oscP5.send(myMessage, myRemoteLocation);
}

