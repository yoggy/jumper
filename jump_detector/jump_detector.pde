import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

Minim minim;
AudioInput  mic_in;

FFT fft;
float [] fft_spec;
int fft_barchart_width;
int fft_idx = 0;
float fft_threshold = 10.0;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;

void setup() {
  size(400, 400);

  minim = new Minim(this);

  mic_in = minim.getLineIn(Minim.MONO, 1024, 44100);
  mic_in.mute();
  fft = new FFT(mic_in.bufferSize(), mic_in.sampleRate());
  fft.window(FFT.HAMMING);
  fft.linAverages(30);
  fft_spec = new float[fft.avgSize()];
  fft_barchart_width = width / fft.avgSize();

  cp5 = new ControlP5(this);
  cp5.setColorForeground(0xff00aa00);
  cp5.setColorBackground(0xff006600);
  cp5.setColorLabel(0xff00dd00);
  cp5.setColorValue(0xff88ff88);
  cp5.setColorActive(0xff00bb00);
  cp5.addSlider("fft_idx").setSize(100,10).setPosition(10,60).setRange(0, fft.avgSize()-1);
  cp5.addSlider("fft_threshold").setSize(100,10).setPosition(10,80).setRange(0, 100);

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
}

void draw() {
  background(0);
  process_mic_in();
  draw_mic_in();
}

void keyPressed() {
  fire_jump();
}

void mousePressed() {
  fire_jump();
}

int guard_counter = 0;
void process_mic_in() {
  fft.forward(mic_in.mix);
  for (int i = 0; i < fft.avgSize(); ++i) {
    fft_spec[i] = fft.getAvg(i);
  }

  int idx = mouseX / fft_barchart_width;
  if (idx <  fft.avgSize()) {
    float freq = fft.indexToFreq(idx);
    println(String.format("idx=%d, freq=%.2f, avg=%.2f", idx, freq, fft.getAvg(idx)));
  }
  
  if (fft.getAvg(fft_idx) > fft_threshold && guard_counter ==0) {
    guard_counter = 30;
    fire_jump();
  }
  
  if (guard_counter > 0) guard_counter --;
}

void fire_jump() {
  OscMessage myMessage = new OscMessage("/jump");
  myMessage.add(123);
  oscP5.send(myMessage, myRemoteLocation);
}

void draw_mic_in() {
  noStroke();
  fill(0, 128, 0);
  for (int i = 0; i < fft_spec.length; i++) {
    rect(i * fft_barchart_width, height, fft_barchart_width, -Math.round(fft_spec[i]*5));
  }
  
  stroke(0,255,0);
  
  line(0, height-Math.round(fft_threshold*5), width, height-Math.round(fft_threshold*5));
  
  fill(0, 255, 0);
  text(String.format("fft_spec[%d]=%.2f", fft_idx, fft_spec[fft_idx]), 200, 80);  
}

