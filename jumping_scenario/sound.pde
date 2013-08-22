Minim minim;
AudioPlayer se_jump;
AudioPlayer se_shutter;

void setup_sound() {
  minim = new Minim(this);

  // http://commons.nicovideo.jp/material/nc27131
  se_jump = minim.loadFile("nc27131.mp3");
  se_jump.setGain(-14.0);

  // http://commons.nicovideo.jp/material/nc2035
  se_shutter = minim.loadFile("nc2035.mp3");
  se_shutter.setGain(-14.0);
}

