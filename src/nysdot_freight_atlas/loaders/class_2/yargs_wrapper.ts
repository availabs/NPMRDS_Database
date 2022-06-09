import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasClass2Loader, {
  NysdotFreightAtlasClass2LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Class2 layer name.",
    demand: true,
    type: "string",
    default: "Class2",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Class2 version (required format: YYYY).",
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

export const loadClass2 = {
  desc: "Load the Class2 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_class_2",
  builder,
  async handler(
    argv: NysdotFreightAtlasClass2LoaderParams
  ) {
    const loader = new NysdotFreightAtlasClass2Loader(
      argv
    );

    loader.loadLayer();
  },
};
