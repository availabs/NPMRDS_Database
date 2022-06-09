import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNystaCountsLoader, {
  NysdotFreightAtlasNystaCountsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas NystaCounts layer name.",
    demand: true,
    type: "string",
    default: "NYSTACounts",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas NystaCounts version (required format: YYYY).",
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

export const loadNystaCounts = {
  desc: "Load the NystaCounts layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_nysta_counts",
  builder,
  async handler(
    argv: NysdotFreightAtlasNystaCountsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNystaCountsLoader(
      argv
    );

    loader.loadLayer();
  },
};
