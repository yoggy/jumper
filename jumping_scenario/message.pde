Vector messages = new Vector();

void clear_message() {
  messages.clear();
}

void show_message(String msg) {
  println("show_message() : msg=" + msg);
  messages.add(msg);
}

void draw_message() {
  noStroke();
  fill(0, 0, 0);
  textFont(font_small);  

  int x = 160;
  int y = 300;  
  for (int i = 0; i < messages.size(); ++i) {
    String msg = (String)messages.get(i);
    text(msg, x, y);
    y += 36;
  }
}



