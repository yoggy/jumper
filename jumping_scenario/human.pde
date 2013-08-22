int  jump_count = 0;
long last_t = 0;
float bpm = 0.0;
float dulation = 0.0;
float human_y = 0.0; // 0.0-1.0
float timeout = 3.0; // (sec)
boolean is_take_picture = false;

void clear_human_status() {
  human_y = 0.0;
  is_take_picture = false;
}

void clear_bpm_status() {
  bpm = 0.0;
  dulation = 0.0;
  jump_count = 0;
}

void calc_initial_human_status(float dt) {
  dulation = dt;
  bpm = frameRate / dt;

  clear_human_status();
}

void fire_jump() {
  clear_message();
  
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

  if (jump_count < scenario.getMaxTick()) {
    jump_count ++;
  }

  // call scenario_player
  scenario.enter(jump_count);
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

void draw_human(float x, float y) {
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

void draw_debug_info() {
  // draw human body
  float x = 60;
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



