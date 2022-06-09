import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMpoBoundariesLoader, {
  NysdotFreightAtlasMpoBoundariesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MpoBoundaries layer name.",
    demand: true,
    type: "string",
    default: "MPO_Boundary",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MpoBoundaries version (required format: YYYY).",
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

export const loadMpoBoundaries = {
  desc: "Load the MpoBoundaries layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_mpo_boundaries",
  builder,
  async handler(
    argv: NysdotFreightAtlasMpoBoundariesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMpoBoundariesLoader(
      argv
    );

    loader.loadLayer();
  },
};
