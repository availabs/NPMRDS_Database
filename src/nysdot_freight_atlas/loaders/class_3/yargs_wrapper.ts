import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasClass3Loader, {
  NysdotFreightAtlasClass3LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Class3 layer name.",
    demand: true,
    type: "string",
    default: "Class3",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Class3 version (required format: YYYY).",
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

export const loadClass3 = {
  desc: "Load the Class3 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_class_3",
  builder,
  async handler(
    argv: NysdotFreightAtlasClass3LoaderParams
  ) {
    const loader = new NysdotFreightAtlasClass3Loader(
      argv
    );

    loader.loadLayer();
  },
};
