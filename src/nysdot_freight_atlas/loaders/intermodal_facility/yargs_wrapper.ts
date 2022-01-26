import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasIntermodalFacilityLoader, {
  NysdotFreightAtlasIntermodalFacilityLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas IntermodalFacility layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas IntermodalFacility version (required format: YYYY).",
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

export const loadIntermodalFacility = {
  desc: "Load the IntermodalFacility layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_intermodal_facility",
  builder,
  async handler(
    argv: NysdotFreightAtlasIntermodalFacilityLoaderParams
  ) {
    const loader = new NysdotFreightAtlasIntermodalFacilityLoader(
      argv
    );

    loader.loadLayer();
  },
};
