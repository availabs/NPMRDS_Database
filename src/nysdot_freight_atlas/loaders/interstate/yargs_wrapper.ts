import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasInterstateLoader, {
  NysdotFreightAtlasInterstateLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Interstate layer name.",
    demand: true,
    type: "string",
    default: "Interstate",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Interstate version (required format: YYYY).",
    demand: true,
    type: "string",
  },
  pg_env: {
    desc: "The database into which to load the Transcom Events.",
    type: "string",
    demand: false,
    choices: Object.values(PGEnv),
    default: PGEnv.DEVELOPMENT,
  },
};

export const loadInterstate = {
  desc: "Load the Interstate layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_interstate",
  builder,
  async handler(
    argv: NysdotFreightAtlasInterstateLoaderParams
  ) {
    const loader = new NysdotFreightAtlasInterstateLoader(
      argv
    );

    loader.loadLayer();
  },
};
