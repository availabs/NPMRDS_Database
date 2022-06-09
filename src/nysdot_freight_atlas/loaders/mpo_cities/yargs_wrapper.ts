import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMpoCitiesLoader, {
  NysdotFreightAtlasMpoCitiesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MpoCities layer name.",
    demand: true,
    type: "string",
    default: "MPO_Cities",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MpoCities version (required format: YYYY).",
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

export const loadMpoCities = {
  desc: "Load the MpoCities layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_mpo_cities",
  builder,
  async handler(
    argv: NysdotFreightAtlasMpoCitiesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMpoCitiesLoader(
      argv
    );

    loader.loadLayer();
  },
};
