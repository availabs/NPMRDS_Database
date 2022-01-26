import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasClass1Loader, {
  NysdotFreightAtlasClass1LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Class1 layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Class1 version (required format: YYYY).",
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

export const loadClass1 = {
  desc: "Load the Class1 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_class_1",
  builder,
  async handler(
    argv: NysdotFreightAtlasClass1LoaderParams
  ) {
    const loader = new NysdotFreightAtlasClass1Loader(
      argv
    );

    loader.loadLayer();
  },
};
