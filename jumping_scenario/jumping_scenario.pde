import processing.serial.*;

//
//  jumping_scenario.pde
//
import ddf.minim.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

// configuration
float shutter_chance = 0.4;  // 0.0-1.0

Minim minim;
AudioPlayer se_jump;
AudioPlayer se_shutter;

ControlP5 cp5;
OscP5 oscP5;
NetAddress myRemoteLocation;

PFont font_small = createFont("Impact", 20);
PFont font_normal = createFont("Impact", 36);
PFont font_large = createFont("Impact", 160);

ScenarioPlayer scenario;

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

void enter_idle_mode() {
  println("enter_idle_mode()");
  clear_bpm_status();
  clear_human_status();
  scenario.rewind();
  clear_message();
}

void Reload_Scenario() {
  scenario.reload();
  enter_idle_mode();
}

void draw() {
  // update human status
  update();
  background(255, 255, 255);
  draw_debug_info();
  draw_message();
}

void stop() {
  se_jump.close();
  se_shutter.close();
  minim.stop();
  super.stop();
}

void keyPressed() {
  switch(key) {
  case 0x20:
    fire_jump();
    break;
  case 'c':
    enter_idle_mode();
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


