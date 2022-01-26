import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlas__LAYER_NAME_CAMEL_UPPER_CASE__Loader, {
  NysdotFreightAtlas__LAYER_NAME_CAMEL_UPPER_CASE__LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas __LAYER_NAME_CAMEL_UPPER_CASE__ layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas __LAYER_NAME_CAMEL_UPPER_CASE__ version (required format: YYYY).",
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

export const load__LAYER_NAME_CAMEL_UPPER_CASE__ = {
  desc: "Load the __LAYER_NAME_CAMEL_UPPER_CASE__ layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas___LAYER_NAME_LOWER_SNAKE_CASE__",
  builder,
  async handler(
    argv: NysdotFreightAtlas__LAYER_NAME_CAMEL_UPPER_CASE__LoaderParams
  ) {
    const loader = new NysdotFreightAtlas__LAYER_NAME_CAMEL_UPPER_CASE__Loader(
      argv
    );

    loader.loadLayer();
  },
};
