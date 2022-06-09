import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasHighwaysLoader, {
  NysdotFreightAtlasHighwaysLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Highways layer name.",
    demand: true,
    type: "string",
    default: "Highways",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Highways version (required format: YYYY).",
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

export const loadHighways = {
  desc: "Load the Highways layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_highways",
  builder,
  async handler(
    argv: NysdotFreightAtlasHighwaysLoaderParams
  ) {
    const loader = new NysdotFreightAtlasHighwaysLoader(
      argv
    );

    loader.loadLayer();
  },
};
