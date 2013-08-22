//
//  SenarioPlayer class
//
//  == how to use
//  ==== data/scenario.txt
//      1 testFunc
//      3 testFunc2 s:string1 s:string2
//      7 testFunc2 s:string3 s:string4
//      10 testFunc
//    
//  ==== SenalioPlayerTest.pde
//      SenarioPlayer scenario;
//      int tick = 0;
//
//      void setup() {
//        scenario = new SenarioPlayer(this);
//        if (scenario.load("scenario.txt") == false) exit();
//        println(scenario.toString());
//      }
//      
//      void draw() {
//        senario.enter(tick);
//        tick ++:
//      }
//
//      void testFunc() {
//        println("testFunc()");
//      }
//
//      void testFunc2(String arg1, String arg2) {
//        println("testFunc2() : arg1="+arg1+","arg2="+arg2);
//      }
//
//  == scenario file line format
//    tick function_name [arg1] [arg2] [arg3] ...
//  
//    example: 
//      1 printTest0
//      2 testFunction   i:123
//      3 testFunction2  i:123 s:abc f:1.0
//
import java.util.*;
import java.lang.reflect.*;

class ScenarioPlayer {
  PApplet papplet;
  HashMap map = new HashMap();
  int max_tick = -1;
  int last_tick = -1;
  boolean debug_mode = false;
  String filename;

  ScenarioPlayer(PApplet papplet) {
    this.papplet = papplet;
  }

  void debugMode(boolean flag) {
    debug_mode = flag;
  }

  int getMaxTick() {
    return max_tick;
  }

  void clear() {
    map.clear();
    max_tick = -1;
  }

  boolean reload() {
    return load(this.filename);
  }

  boolean load(String filename) {  
    clear();

    String lines[] = loadStrings(filename);
    if (lines == null) {
      println("SenarioPlayer.load() : loadStrings() failed...filename=" + filename);
      clear();
      return false;
    }

    // parse scenario file    
    for (int i = 0; i < lines.length; ++i) {
      if (parseLine(lines[i]) == false) {
        println("SenarioPlayer.load() failed...line=" + (i+1) + ", str=" + lines[i]);
        clear();
        return false;
      }
    } 

    if (debug_mode) {
      println("======== load scenario ========");
      println(toString());
      println("===============================");
    }

    this.filename = filename;
    
    return true;
  }

  boolean parseLine(String line) {
    if (line == null) return false;

    String striped_line = strip(line);
    String [] words = striped_line.split(" ", 0);
    
    // check line
    if (words == null || words.length == 0) return true;
    if (words[0].length() == 0) return true;               // null line
    if ("#".equals(words[0].substring(0, 1))) return true; // comment

    // remove 0 width string...
    Vector vw = new Vector();
    for (int i = 0; i < words.length; ++i) {
      if (words[i].length() == 0) continue;
      vw.add(words[i]);
    }
    words = (String[])vw.toArray(new String[0]);
    if (words.length < 2) {
      return false;
    }

    // parse line
    int tick;
    if ("=".equals(words[0])) {
      tick = last_tick;
    }
    else if ("+".equals(words[0])) {
      tick = last_tick + 1;
    }
    else {
      tick = int(words[0]);
    }

    String function_name = words[1];

    String [] args = null;
    int argc = words.length - 2;
    if (argc > 0) {
      Vector v = new Vector();
      for (int j = 0; j < argc; ++j) {
        String w = words[j + 2];
        if (w.length() == 0) continue;
        if ("#".equals(w.substring(0, 1))) break;
        v.add(w);
      }
      args = new String[v.size()];
      v.copyInto(args);
    }

    // create & append command
    try {
      Command cmd = new Command(papplet, tick, function_name, args);      
      appendCommand(cmd);
    }
    catch(Exception e) {
      return false;
    }

    last_tick = tick;

    return true;
  }

  void appendCommand(Command cmd) {
    Vector v;
    if (map.containsKey(cmd.tick)) {
      v = (Vector)map.get(cmd.tick);
    }
    else {
      v = new Vector();
      map.put(cmd.tick, v);
    }
    v.add(cmd);

    if (cmd.tick > max_tick) {
      max_tick = cmd.tick;
    }
  }

  Command [] getCommands(int tick) {
    Command [] cmds = null;
    if (map.containsKey(tick)) {
      Vector v = (Vector)map.get(tick);
      if (v != null && v.size() > 0) {
        cmds = (Command[])v.toArray(new Command[0]);
      }
    }
    return cmds;
  }

  void rewind() {
    Integer [] keys = (Integer[])map.keySet().toArray(new Integer[0]);
    for (int i = 0; i < keys.length; ++i) {
      Command [] cmds = getCommands(keys[i]);
      for (int j = 0; j < cmds.length; ++j) {
        cmds[j].clear();
      }
    }
  }

  void enter(int tick) {
    if (debug_mode) println("======== enter; tick=" + tick + "========");
    if (map.containsKey(tick)) {
      Command [] cmds = getCommands(tick);
      for (int i = 0; i < cmds.length; ++i) {
        cmds[i].call();
      }
    }
  }

  String strip(String str) {
    if (str == null || str.length() == 0) return str;

    int idx_s, idx_e = str.length() - 1;    
    for (idx_s = 0; idx_s < idx_e; ++idx_s) {
      if (Character.isWhitespace(str.charAt(idx_s))) {
        continue;
      }
      break;
    }
    for (;idx_s <= idx_e; --idx_e) {
      if (Character.isWhitespace(str.charAt(idx_e))) {
        continue;
      }
      break;
    }

    return str.substring(idx_s, idx_e + 1);
  }

  String toString() {
    String msg = "ScenarioPlayer{";
    if (map.size() == 0) {
      msg += "empty";
    }
    else {
      msg += "\n";
      Integer [] keys = (Integer[])map.keySet().toArray(new Integer[0]);
      for (int i = 0; i < keys.length; ++i) {
        Command [] cmds = getCommands(keys[i]);
        for (int j = 0; j < cmds.length; ++j) {
          msg += "    ";
          msg += cmds[j].toString();
          msg += "\n";
        }
      }
    }
    msg += "}";
    return msg;
  }
}

class Command {
  PApplet papplet;
  int tick;
  String function_name;
  Object [] args;
  boolean is_called;

  Method method;

  Command(PApplet papplet, int tick, String function_name, String [] args) throws Exception {
    this.papplet = papplet;
    this.tick = tick;
    this.function_name = function_name;
    this.is_called = false;

    try {
      Class [] obj_args = null;
      this.args = null;
      if (args != null) {
        this.args = new Object[args.length];
        obj_args = new Class[args.length];

        for (int i = 0; i < args.length; ++i) {
          String type = args[i].substring(0, 1);
          if ("s".equals(type)) {
            this.args[i] = args[i].substring(2, args[i].length());
            obj_args[i] = String.class;
          }
          else if ("i".equals(type)) {
            this.args[i] = int(args[i].substring(2, args[i].length()));
            obj_args[i] = int.class;
          }
          else if ("f".equals(type)) {
            this.args[i] = float(args[i].substring(2, args[i].length()));
            obj_args[i] = float.class;
          }
          else if ("b".equals(type)) {
            this.args[i] = "true".equals(args[i].substring(2, args[i].length())) ? true : false;
            obj_args[i] = boolean.class;
          }
        }
      }
      method = papplet.getClass().getMethod(function_name, obj_args);
    }
    catch(Exception e) {
      System.err.print("Command(): function is not found...function_name=" + function_name + ", args=");
      if (args == null) {
        System.err.print("args=null");
      }
      else {
        for (int i = 0; i < args.length; ++i) {
          System.err.print("arg" + i + "=" + args[i]);
          if (i < args.length - 1) System.err.print(", ");
        }
      }
      System.err.println("");
      e.printStackTrace();
      method = null;
      throw e;
    }
  }

  void call() {
    // check
    if (is_called == true) return;
    is_called = true;

    try {
      method.invoke(papplet, args);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  void clear() {
    is_called = false;
  }

  String toString() {
    String msg = "";
    msg = "Command{tick=" + tick + ", fn=" + function_name + ", ";

    if (args == null) {
      msg += "args=null";
    }
    else {
      for (int i = 0; i < args.length; ++i) {
        msg += "arg" + i + "=" + args[i];
        if (i < args.length - 1) msg += ",";
      }
    }

    msg += "}";
    return msg;
  }
}

