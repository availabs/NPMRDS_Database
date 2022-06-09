import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNysdotRegionsLoader, {
  NysdotFreightAtlasNysdotRegionsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas NysdotRegions layer name.",
    demand: true,
    type: "string",
    default: "NYSDOT_Regions",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas NysdotRegions version (required format: YYYY).",
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

export const loadNysdotRegions = {
  desc: "Load the NysdotRegions layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_nysdot_regions",
  builder,
  async handler(
    argv: NysdotFreightAtlasNysdotRegionsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNysdotRegionsLoader(
      argv
    );

    loader.loadLayer();
  },
};
