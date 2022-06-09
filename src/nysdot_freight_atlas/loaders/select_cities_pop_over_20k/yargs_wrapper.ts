import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasSelectCitiesPopOver20KLoader, {
  NysdotFreightAtlasSelectCitiesPopOver20KLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas SelectCitiesPopOver20K layer name.",
    demand: true,
    type: "string",
    default: "SelectCities_PopOver20k",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas SelectCitiesPopOver20K version (required format: YYYY).",
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

export const loadSelectCitiesPopOver20K = {
  desc: "Load the SelectCitiesPopOver20K layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_select_cities_pop_over_20k",
  builder,
  async handler(
    argv: NysdotFreightAtlasSelectCitiesPopOver20KLoaderParams
  ) {
    const loader = new NysdotFreightAtlasSelectCitiesPopOver20KLoader(
      argv
    );

    loader.loadLayer();
  },
};
