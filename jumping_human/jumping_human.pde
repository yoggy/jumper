//
//  jumping_human.pde
//
import ddf.minim.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

// configuration
float shutter_chance = 0.2;  // 0.0-1.0
int shutter_count = 8;

int jump_count = 0;
long last_t = 0;
float bpm = 0.0;
float dulation = 0.0;
float human_y = 0.0; // 0.0-1.0
float timeout = 3.0; // (sec)
boolean is_take_picture = false;
int picture_frame_counter = 0;
float picture_frame_x;
float picture_frame_y;

Minim minim;
AudioPlayer se_jump;
AudioPlayer se_shutter;
AudioInput  mic_in;

OscP5 oscP5;
NetAddress myRemoteLocation;

PFont font_normal = createFont("Impact", 36);
PFont font_large = createFont("Impact", 360);

ControlP5 cp5;

void setup() {
  size(480, 640);
  
  minim = new Minim(this);

  // http://commons.nicovideo.jp/material/nc27131
  se_jump = minim.loadFile("nc27131.mp3");
  se_jump.setGain(-14.0);

  // http://commons.nicovideo.jp/material/nc2035
  se_shutter = minim.loadFile("nc2035.mp3");
  se_shutter.setGain(-14.0);

  cp5 = new ControlP5(this);
  cp5.setColorForeground(0xff00aa00);
  cp5.setColorBackground(0xff006600);
  cp5.setColorLabel(0xff00dd00);
  cp5.setColorValue(0xff88ff88);
  cp5.setColorActive(0xff00bb00);

  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12002);
}

void update() {
  if (bpm == 0.0) {
    clear_human_status();
    return;
  }

  float dt = (millis() - last_t) / 1000.0;
  if (dt > timeout) {
    clear_bpm_status();
    clear_human_status();
    return;
  }

  // calculate human position (0.0-1.0)
  float p = dt / dulation;
  if (p >= 1.0) p = 1.0;
  float th = PI * p;

  human_y = sin(th);
}

void draw() {
  update();

  background(0, 0, 0);

  // draw human body
  float x = 120;
  float y = (height * 0.7) * (1.0 - human_y) + height * 0.3;
  draw_human(x, y);

  // check shutter chance
  float p = (millis() - last_t) / 1000.0 / dulation;
  if (is_take_picture == false && human_y > 0.0 && p >= shutter_chance) {
    take_picture(x, y);
  }
  draw_picture_frame();

  noStroke();

  // draw jump count
  fill(0, 255, 0);
  textFont(font_large);  
  text(String.format("%d", jump_count), 240, 500);

  // debug info
  fill(0, 128, 0);
  textFont(font_normal);  
  text(String.format("bpm=%.2f, dulation=%.2f(s)", bpm, dulation), 20, 30);
}

void stop() {
  se_jump.close();
  se_shutter.close();
  mic_in.close();
  minim.stop();
  super.stop();
}

void keyPressed() {
  fire_jump();
}

void mousePressed() {
  fire_jump();
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/jump")==true) {
    fire_jump();
  }
}

void fire_jump() {
  long t = millis();
  float dt = (t - last_t) / 1000.0;

  if (dt < timeout) {
    calc_initial_human_status(dt);
    se_jump.play(0);
  }
  else {
    clear_bpm_status();
  }
  last_t = t;

  if (jump_count == 0) {
    // set initiali value...
    bpm = 120.0;
    dulation = 0.5;
  }
  jump_count ++;
  if (jump_count == shutter_count) jump_count = 0;
}

void calc_initial_human_status(float dt) {
  dulation = dt;
  bpm = frameRate / dt;

  clear_human_status();
}

void clear_human_status() {
  human_y = 0.0;
  is_take_picture = false;
}

void clear_bpm_status() {
  bpm = 0.0;
  dulation = 0.0;
  jump_count = 0;
}

void draw_human(float  x, float y) {
  noStroke();
  fill(0, 128, 0);

  ellipseMode(CENTER);
  ellipse(x, y - 100, 50, 50);

  stroke(0, 128, 0);
  strokeWeight(2);
  line(x, y - 100, x, y - 40);
  line(x - 30, y -  60, x + 30, y - 60);
  line(x, y -  40, x - 20, y     );
  line(x, y -  40, x + 20, y     );
}

void take_picture(float x, float y) {
  is_take_picture = true;
  picture_frame_counter = 0;

  picture_frame_x = x;
  picture_frame_y = y;
  
  // send osc 
  if (jump_count == 0) {
    se_shutter.play(0);

    OscMessage myMessage = new OscMessage("/take_picture");
    myMessage.add(123);
    oscP5.send(myMessage, myRemoteLocation);
  }
}

void draw_picture_frame() {
  if (is_take_picture == false) return;
  if (picture_frame_counter >= 6) return;

  stroke(255, 255, 255);
  strokeWeight(20);
  noFill();

  //rect(picture_frame_x - 100, picture_frame_y - 150, 200, 200);  

  picture_frame_counter ++;
}

