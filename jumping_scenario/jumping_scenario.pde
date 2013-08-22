//
//  jumping_scenario.pde
//
import ddf.minim.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

// configuration
float shutter_chance = 0.4;  // 0.0-1.0

int  jump_count = 0;
long last_t = 0;
float bpm = 0.0;
float dulation = 0.0;
float human_y = 0.0; // 0.0-1.0
float timeout = 3.0; // (sec)
boolean is_take_picture = false;

Minim minim;
AudioPlayer se_jump;
AudioPlayer se_shutter;
AudioInput  mic_in;

OscP5 oscP5;
NetAddress myRemoteLocation;

PFont font_normal = createFont("Impact", 36);
PFont font_large = createFont("Impact", 160);

ScenarioPlayer scenario;

ControlP5 cp5;
void init() {
  frame.removeNotify();
  //frame.setUndecorated(true);
  frame.addNotify();
  super.init();
}

void setup() {
  size(640, 640);

  minim = new Minim(this);

  // http://commons.nicovideo.jp/material/nc27131
  se_jump = minim.loadFile("nc27131.mp3");
  se_jump.setGain(-14.0);

  // http://commons.nicovideo.jp/material/nc2035
  se_shutter = minim.loadFile("nc2035.mp3");
  se_shutter.setGain(-14.0);

  cp5 = new ControlP5(this);  
  cp5.addSlider("shutter_chance").setPosition(10, 50).setSize(300, 40).setRange(0.0, 1.0);
  cp5.addButton("Reload_Scenario").setPosition(10, 100).setSize(100, 40);

  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12002);

  scenario = new ScenarioPlayer(this);
  if (scenario.load("scenario.txt") == false) {
    println("scenario.load() failed...");
    exit();
  }
}

void Reload_Scenario() {
  scenario.reload();
}

void enter_idle_mode() {
  println("enter_idle_mode()");
  clear_bpm_status();
  clear_human_status();
  scenario.rewind();
}

void update() {
  if (bpm == 0.0) {
    clear_human_status();
    return;
  }

  float dt = (millis() - last_t) / 1000.0;
  if (dt > timeout) {
    enter_idle_mode();
    return;
  }

  // calculate human position (0.0-1.0)
  float p = dt / dulation;
  if (p >= 1.0) p = 1.0;
  float th = PI * p;

  human_y = sin(th);

  // check shutter chance
  if (is_take_picture == false && human_y > 0.0 && p >= shutter_chance) {
  }
}

void draw() {
  // update human status
  update();

  background(255, 255, 255);

  draw_debug_info();
}

void draw_debug_info() {
  // draw human body
  float x = 120;
  float y = (height * 0.5) * (1.0 - human_y) + height * 0.5;
  draw_human(x, y);

  noStroke();

  // draw jump count
  fill(0, 0, 0);
  textFont(font_large);  
  text(String.format("%d", jump_count), 160, 260);

  // debug info
  fill(0, 0, 0);
  textFont(font_normal);  
  text(String.format("bpm=%.2f, dulation=%.2f(s)", bpm, dulation), 20, 35);
}

void stop() {
  se_jump.close();
  se_shutter.close();
  mic_in.close();
  minim.stop();
  super.stop();
}

void keyPressed() {
  switch(key) {
  case 0x20:
    fire_jump();
    break;
  }
}

void mousePressed() {
  //fire_jump();
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

  if (jump_count <= scenario.getMaxTick()) {
    jump_count ++;
  }

  // call scenario_player
  scenario.enter(jump_count);
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
  fill(0, 0, 0);

  ellipseMode(CENTER);
  ellipse(x, y - 100, 50, 50);

  stroke(0, 0, 0);
  strokeWeight(4);
  line(x, y - 100, x, y - 40);
  line(x - 30, y -  60, x + 30, y - 60);
  line(x, y -  40, x - 20, y     );
  line(x, y -  40, x + 20, y     );
}

