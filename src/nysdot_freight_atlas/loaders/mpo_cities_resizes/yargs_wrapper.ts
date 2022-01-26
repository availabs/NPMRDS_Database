import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMpoCitiesResizesLoader, {
  NysdotFreightAtlasMpoCitiesResizesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MpoCitiesResizes layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MpoCitiesResizes version (required format: YYYY).",
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

export const loadMpoCitiesResizes = {
  desc: "Load the MpoCitiesResizes layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_mpo_cities_resizes",
  builder,
  async handler(
    argv: NysdotFreightAtlasMpoCitiesResizesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMpoCitiesResizesLoader(
      argv
    );

    loader.loadLayer();
  },
};
