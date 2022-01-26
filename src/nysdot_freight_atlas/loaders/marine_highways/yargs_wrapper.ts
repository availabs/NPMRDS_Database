import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMarineHighwaysLoader, {
  NysdotFreightAtlasMarineHighwaysLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MarineHighways layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MarineHighways version (required format: YYYY).",
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

export const loadMarineHighways = {
  desc: "Load the MarineHighways layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_marine_highways",
  builder,
  async handler(
    argv: NysdotFreightAtlasMarineHighwaysLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMarineHighwaysLoader(
      argv
    );

    loader.loadLayer();
  },
};
