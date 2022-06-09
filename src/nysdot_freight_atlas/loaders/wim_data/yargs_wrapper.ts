import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasWimDataLoader, {
  NysdotFreightAtlasWimDataLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas WimData layer name.",
    demand: true,
    type: "string",
    default: "WIMData",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas WimData version (required format: YYYY).",
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

export const loadWimData = {
  desc: "Load the WimData layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_wim_data",
  builder,
  async handler(
    argv: NysdotFreightAtlasWimDataLoaderParams
  ) {
    const loader = new NysdotFreightAtlasWimDataLoader(
      argv
    );

    loader.loadLayer();
  },
};
