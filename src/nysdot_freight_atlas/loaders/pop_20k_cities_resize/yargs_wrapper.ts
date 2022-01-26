import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasPop20KCitiesResizeLoader, {
  NysdotFreightAtlasPop20KCitiesResizeLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Pop20KCitiesResize layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Pop20KCitiesResize version (required format: YYYY).",
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

export const loadPop20KCitiesResize = {
  desc: "Load the Pop20KCitiesResize layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_pop_20k_cities_resize",
  builder,
  async handler(
    argv: NysdotFreightAtlasPop20KCitiesResizeLoaderParams
  ) {
    const loader = new NysdotFreightAtlasPop20KCitiesResizeLoader(
      argv
    );

    loader.loadLayer();
  },
};
