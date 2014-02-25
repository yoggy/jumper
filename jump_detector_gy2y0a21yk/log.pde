//
// for logging
//
import java.io.*;

boolean enable_logging = true;

String log_filename_ = "log.txt";
PrintWriter log_pw_ = null;

synchronized void log(String operation_type, String... args) {
  if (enable_logging == false) return;
  
  try {
    if (log_pw_ == null) {
      new File(dataPath("")).mkdir();
      File f = new File(dataPath(log_filename_));
      log_pw_ = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    }

    String args_str = "";
    for (int i = 0; i < args.length; ++i) {
      args_str += args[i];
      if (i < args.length - 1) {
        args_str += ",";
      }
    }

    long t = System.currentTimeMillis();
    log_pw_.println("" + t + "," + operation_type + "," + args_str);
    log_pw_.flush();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

