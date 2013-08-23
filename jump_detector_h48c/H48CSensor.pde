import processing.serial.*;
import java.util.*;

class H48CSensor {
  PApplet papplet_;
  Serial serial_;

  float ax_, ay_, az_;
  float old_ax_, old_ay_, old_az_;
  float diff_ax_, diff_ay_, diff_az_;
  float diff_;
  Vector diff_history_ = new Vector();
  float t_;
  boolean zero_g_;
  int last_update_frame_;

  int [] buf_ = new int[12];
  int buf_idx_;

  H48CSensor(PApplet papplet) {
    this.papplet_ = papplet;
  }

  boolean open(String port) {
    serial_ = new Serial(papplet_, port, 115200);
    if (serial_ == null) {
      return false;
    }
    return true;
  }

  void close() {
    if (serial_ != null) {
      serial_.stop();
      serial_ = null;
    }
  }

  boolean is_alive() {
    if (frameCount - last_update_frame_ < frameRate) return true;
    return false;
  }

  void recv() {
    while (serial_.available () > 0) {
      int c = serial_.read();
      if (c == -1) return;

      buf_[buf_idx_] = c;
      if (buf_idx_ < buf_.length - 1) buf_idx_ ++;
      if (c == '#') parse_buffer_();

      last_update_frame_ = frameCount;
    }
  }

  void parse_buffer_() {
    // check
    if (buf_idx_ != 11) {
      buf_idx_ = 0;
      return;
    }

    // clear buffer
    buf_idx_ = 0;

    if (buf_[0] != '@') return;
    if (buf_[1] != 'A') return;

    short sx, sy, sz, st;
    sx = (short)(((buf_[2] << 8) & 0xff00) | (buf_[3] & 0x00ff));
    sy = (short)(((buf_[4] << 8) & 0xff00) | (buf_[5] & 0x00ff));
    sz = (short)(((buf_[6] << 8) & 0xff00) | (buf_[7] & 0x00ff));
    st = (short)(((buf_[8] << 8) & 0xff00) | (buf_[9] & 0x00ff));

    ax_ = sx * 2.933f / 333.0f;
    ay_ = sy * 2.933f / 333.0f;
    az_ = sz * 2.933f / 333.0f;
    t_  = st * 2.933f / 10 + 25;

    zero_g_ = buf_[10] == '1' ? true : false;

    float p = 0.97f;
    old_ax_ = old_ax_ * p + ax_ * (1.0f - p);
    old_ay_ = old_ay_ * p + ay_ * (1.0f - p);
    old_az_ = old_az_ * p + az_ * (1.0f - p);

    diff_ax_ = ax_ - old_ax_;
    diff_ay_ = ay_ - old_ay_;
    diff_az_ = az_ - old_az_;

    diff_ = sqrt(diff_ax_ * diff_ax_ + diff_ay_ * diff_ay_ + diff_az_ * diff_az_);
    
    diff_history_.add(diff_);
    if (diff_history_.size() > 1024) {
      diff_history_.remove(0);
      diff_history_.trimToSize();
    }
  }

  float diff() {
    return diff_;
  }
  
  float diff(int n) {
    float max_val = 0.0f;
    int st = diff_history_.size() - n;
    if (st < 0) st = 0;
    int et = diff_history_.size() - 1;

    for (int i =  st; i <= et; i++) {
      float d = (Float)diff_history_.get(i);
      if (d > max_val) max_val = d;
    }
    return max_val;
  }

  Vector diff_history() {
    return diff_history_;
  }

  void draw_chart(int offset_x, int offset_y, int width, int height, float scale) {
    stroke(0, 255, 0);
    for (int i = 0; i < diff_history_.size() - 1; ++i) {
      float d0 = (Float)diff_history_.get(i);
      float d1 = (Float)diff_history_.get(i+1);

      float y0 = d0 * (height / scale);
      float y1 = d1 * (height / scale);

      float x0 = i     / (float)diff_history_.size() * width;
      float x1 = (i+1) / (float)diff_history_.size() * width;

      line(offset_x + x0, offset_y + y0, offset_x + x1, offset_y + y1);
    }
  }
}

