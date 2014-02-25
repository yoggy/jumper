//
// for logging
//
import java.io.*;

boolean enable_logging = true;

String log_filename_ = "log.txt";
PrintWriter log_pw_ = null;

synchronized void log(String operation_type, String arg) {
  if (enable_logging == false) return;
  
  try {
    if (log_pw_ == null) {
      new File(dataPath("")).mkdir();
      File f = new File(dataPath(log_filename_));
      log_pw_ = new PrintWriter(new BufferedWriter(new FileWriter(f)));
    }

    long t = System.currentTimeMillis();
    log_pw_.println("" + t + "," + operation_type + "," + arg);
    log_pw_.flush();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

