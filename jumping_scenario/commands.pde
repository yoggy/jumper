NetAddress remote_location;
NetAddress remote_location2;
boolean fire_take_picture_flag = false;
boolean fire_take_picture_flag2 = false;

Random random = new Random();

void setup_commands() {
  remote_location  = new NetAddress("127.0.0.1", 12002);  
  remote_location2 = new NetAddress("127.0.0.1", 12002); 
}

void nop() {
  show_message("nop");
}

void show_overlay(String filename) {
  show_message("show_overlay " + filename);

  OscMessage msg = new OscMessage("/show_overlay");
  msg.add(filename);
  oscP5.send(msg, remote_location);
}

void hide_overlay() {
  show_message("hide_overlay");

  OscMessage msg = new OscMessage("/hide_overlay");
  oscP5.send(msg, remote_location);
}

void set_effect(int val) {
  show_message("set_effect " + val);

  OscMessage msg = new OscMessage("/set_effect");
  msg.add(val);
  oscP5.send(msg, remote_location);
}

void reset_effect() {
  show_message("reset_effect");

  OscMessage msg = new OscMessage("/reset_effect");
  oscP5.send(msg, remote_location);
}

void change_effect_random() {
  show_message("change_effect_random");

  set_effect(random.nextInt(10));  // sample value 0-9
}

void take_picture() {
  show_message("take_picture");

  // set fire flag
  fire_take_picture_flag = true;
  fire_take_picture_flag2 = true;
}

void fire_take_picture() {
  println("fire_take_picture!!!!");
  se_shutter.play(0);

  OscMessage msg = new OscMessage("/take_picture");
  oscP5.send(msg, remote_location);
}

// for nex-5r
void fire_take_picture2() {
  println("fire_take_picture2!!!!");

  OscMessage msg = new OscMessage("/take_picture");
  oscP5.send(msg, remote_location2);
}

