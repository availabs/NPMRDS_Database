import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCapitalRegionLoader, {
  NysdotFreightAtlasCapitalRegionLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas CapitalRegion layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas CapitalRegion version (required format: YYYY).",
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

export const loadCapitalRegion = {
  desc: "Load the CapitalRegion layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_capital_region",
  builder,
  async handler(
    argv: NysdotFreightAtlasCapitalRegionLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCapitalRegionLoader(
      argv
    );

    loader.loadLayer();
  },
};
