import { execSync } from "child_process";
import { mkdirSync } from "fs";
import { join } from "path";

import fileStreamRotator from "file-stream-rotator";

const logDir = join(__dirname, "../logs/");

mkdirSync(logDir, { recursive: true });

const logStream = fileStreamRotator.getStream({
  filename: join(logDir, "here-realtime-traffic-etl-%DATE%.log"),
  verbose: false,
  frequency: "15m",
  date_format: "YYYYMMDDTHHmm",
  create_symlink: true,
  symlink_name: "here-realtime-traffic-etl-current",
});

function compressFile(filePath: string) {
  try {
    execSync(`gzip -9 ${filePath}`);
  } catch (err) {
    // If running multiple processes, other process may have already gzipped the file.
  }
}

class Logger {
  log(...messages: any[]) {
    for (const message of messages) {
      if (message instanceof Error) {
        logStream.write("===== ERROR =====\n");
        logStream.write(message.message);
        logStream.write("\n");
        logStream.write(message.stack);
      } else {
        const msg =
          typeof message !== "string"
            ? JSON.stringify(message, null, 4)
            : message;

        logStream.write(msg);
        logStream.write(" ");
      }
    }
    logStream.write("\n");
  }

  info(...messages: any[]) {
    this.log(...messages);
  }

  warn(...messages: any[]) {
    this.log(...messages);
  }

  error(...messages: any[]) {
    logStream.write("===== ERROR =====\n");
    this.log(...messages);
  }
}

logStream.on("rotate", (oldFile: string) => {
  compressFile(oldFile);
});

export default new Logger();
