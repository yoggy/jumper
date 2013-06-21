import oscP5.*;
import netP5.*;
import net.sabamiso.processing.nex6.*;
import java.util.*;

Nex6 nex6;
Vector images = new Vector();

OscP5 oscP5;
TakePictureLock take_picture_lock;

float scale = 3;

public void setup() {
  size((int)(1080/scale*5), (int)(1080/scale*3));

  take_picture_lock = new TakePictureLock();

  oscP5 = new OscP5(this, 12345);

  nex6 = new Nex6(this);
  boolean rv = nex6.start();
  if (rv == false) {
    println("error: nex6.start() failed...");
    return;
  }
}

public void draw() {
  int x = 0;
  int y = 0;
  for (int i = images.size() - 1; i >= 0 ; --i) {
    PImage img = (PImage)images.get(i);
    image(img, x, y);
    x += img.width;
    if (x + img.width > width) {
      x = 0;
      y += img.height;
    }
  }
}

public void mousePressed() {
  takePicture();
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/take_picture")==true) {
    takePicture();
  }
}

void takePicture() {
  if (take_picture_lock.isLock() == false) {
    take_picture_lock.lock();
    TakePictureThread thread = new TakePictureThread();
    thread.start();
  }
}

////////////////////////////////////////////////////////////////

class TakePictureThread extends Thread {
  public TakePictureThread() {
  }

  void run() {
    PImage img = nex6.takePicture(); // picture size : 1616 x 1080

    if (img != null) {
      // resize & crop image
      img.resize((int)(img.width/scale), (int)(img.height/scale));  
      PImage resize_img = img.get((img.width-img.height)/2, 0, img.height, img.height);
      images.add(resize_img);
      if (images.size() > 32) images.remove(0);
    }
    take_picture_lock.unlock();
    println("finsh_download");
  }
}

class TakePictureLock {
  boolean flag;

  public synchronized void lock() {
    flag = true;
  }

  public synchronized void unlock() {
    flag = false;
  }

  public synchronized boolean isLock() {
    return flag;
  }
}

