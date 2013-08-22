//
//  jumping_scenario.pde
//
import processing.serial.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

// configuration
float shutter_chance  = 0.4;  // 0.0-1.0
float shutter_chance2 = 0.3;  // 0.0-1.0

ControlP5 cp5;
OscP5 oscP5;

PFont font_small = createFont("Impact", 24);
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
  size(600, 480);

  cp5 = new ControlP5(this);  
  cp5.addSlider("shutter_chance").setPosition(10, 50).setSize(300, 20).setRange(0.0, 1.0);
  cp5.addSlider("shutter_chance2").setPosition(10, 75).setSize(300, 20).setRange(0.0, 1.0);
  cp5.addButton("Reload_Scenario").setPosition(10, 100).setSize(100, 40);

  setup_sound();
  setup_commands();

  scenario = new ScenarioPlayer(this);
  if (scenario.load("scenario.txt") == false) {
    println("scenario.load() failed...");
    exit();
  }

  setup_idle_mode();

  oscP5 = new OscP5(this, 12001);
}

void Reload_Scenario() {
  scenario.reload();
  scenario_idle_mode.reload();
  enter_idle_mode();
}

void draw() {
  update_human_status();
  background(255, 255, 255);

  if (is_idle_mode()) {
    draw_idle_mode();
  }

  draw_debug_info();
  draw_message();
  draw_logo();
}

void draw_logo() {
  fill(0, 0, 0);
  textFont(font_normal);
  text("jumping_scenario.pde", width - 360, height - 10);
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

