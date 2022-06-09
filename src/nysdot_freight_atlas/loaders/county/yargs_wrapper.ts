import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCountyLoader, {
  NysdotFreightAtlasCountyLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas County layer name.",
    demand: true,
    type: "string",
    default: "County",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas County version (required format: YYYY).",
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

export const loadCounty = {
  desc: "Load the County layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_county",
  builder,
  async handler(
    argv: NysdotFreightAtlasCountyLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCountyLoader(
      argv
    );

    loader.loadLayer();
  },
};
