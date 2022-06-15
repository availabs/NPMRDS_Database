import { join } from "path";

import DownloadablesCreator from "./DownloadablesCreator";

async function main() {
  const dc = new DownloadablesCreator(
    "production",
    join(process.cwd(), "test_output")
  );
  await dc.run();
  // await dc.updateDataManagerDownloadablesUrls();
}

main();
