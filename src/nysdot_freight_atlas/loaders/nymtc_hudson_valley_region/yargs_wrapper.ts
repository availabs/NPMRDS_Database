import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNymtcHudsonValleyRegionLoader, {
  NysdotFreightAtlasNymtcHudsonValleyRegionLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas NymtcHudsonValleyRegion layer name.",
    demand: true,
    type: "string",
    default: "NYMTC_HudsonValleyRegion",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas NymtcHudsonValleyRegion version (required format: YYYY).",
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

export const loadNymtcHudsonValleyRegion = {
  desc: "Load the NymtcHudsonValleyRegion layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_nymtc_hudson_valley_region",
  builder,
  async handler(
    argv: NysdotFreightAtlasNymtcHudsonValleyRegionLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNymtcHudsonValleyRegionLoader(
      argv
    );

    loader.loadLayer();
  },
};
