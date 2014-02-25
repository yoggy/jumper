import ddf.minim.*;

int idle_mode_counter = 0;
int idle_mode_t = 0;

ScenarioPlayer scenario_idle_mode;

void setup_idle_mode() {
  scenario_idle_mode = new ScenarioPlayer(this);
  if (scenario_idle_mode.load("scenario_idle_mode.txt") == false) {
    println("scenario_idle_mode.load() failed...");
    exit();
  }
}

boolean is_idle_mode() {
  if (bpm == 0.0f) return true;
  return false;
}

void enter_idle_mode() {
  println("enter_idle_mode");
  log("enter_idle_mode");
  clear_bpm_status();
  clear_human_status();

  idle_mode_counter = 0;
  idle_mode_t = 0;

  clear_message();

  scenario.rewind();
  scenario_idle_mode.rewind();
}

void draw_idle_mode() {
  process_tick();

  fill(0, 0, 0);
  textFont(font_normal);

  text("idle_mode t=" + idle_mode_t, width - 300, height - 50);
}

void process_tick() {
  if (idle_mode_counter % 60 == 0) {
    process_sec();
  }
  idle_mode_counter ++;
}

void process_sec() {
  // check 
  if (scenario_idle_mode.getMaxTick() <= 0) return;
  
  idle_mode_t = (idle_mode_counter / 60) % scenario_idle_mode.getMaxTick();
  if (idle_mode_t == 0) {
    scenario_idle_mode.rewind();
  }

  clear_message();
  scenario_idle_mode.enter(idle_mode_t);
}

