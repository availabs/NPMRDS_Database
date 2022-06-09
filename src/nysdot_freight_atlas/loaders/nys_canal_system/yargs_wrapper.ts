import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNysCanalSystemLoader, {
  NysdotFreightAtlasNysCanalSystemLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas NysCanalSystem layer name.",
    demand: true,
    type: "string",
    default: "NYS_Canal_System",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas NysCanalSystem version (required format: YYYY).",
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

export const loadNysCanalSystem = {
  desc: "Load the NysCanalSystem layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_nys_canal_system",
  builder,
  async handler(
    argv: NysdotFreightAtlasNysCanalSystemLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNysCanalSystemLoader(
      argv
    );

    loader.loadLayer();
  },
};
