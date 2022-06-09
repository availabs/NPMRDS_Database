import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasStateLoader, {
  NysdotFreightAtlasStateLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas State layer name.",
    demand: true,
    type: "string",
    default: "State",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas State version (required format: YYYY).",
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

export const loadState = {
  desc: "Load the State layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_state",
  builder,
  async handler(
    argv: NysdotFreightAtlasStateLoaderParams
  ) {
    const loader = new NysdotFreightAtlasStateLoader(
      argv
    );

    loader.loadLayer();
  },
};
