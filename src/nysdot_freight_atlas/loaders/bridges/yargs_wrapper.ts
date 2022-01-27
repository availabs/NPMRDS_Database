import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasBridgesLoader, {
  NysdotFreightAtlasBridgesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Bridges layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Bridges version (required format: YYYY).",
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

export const loadBridges = {
  desc: "Load the Bridges layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_bridges",
  builder,
  async handler(
    argv: NysdotFreightAtlasBridgesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasBridgesLoader(
      argv
    );

    loader.loadLayer();
  },
};
