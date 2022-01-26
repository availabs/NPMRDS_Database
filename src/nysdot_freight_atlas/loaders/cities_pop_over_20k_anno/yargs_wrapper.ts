import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCitiesPopOver20KAnnoLoader, {
  NysdotFreightAtlasCitiesPopOver20KAnnoLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas CitiesPopOver20KAnno layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas CitiesPopOver20KAnno version (required format: YYYY).",
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

export const loadCitiesPopOver20KAnno = {
  desc: "Load the CitiesPopOver20KAnno layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_cities_pop_over_20k_anno",
  builder,
  async handler(
    argv: NysdotFreightAtlasCitiesPopOver20KAnnoLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCitiesPopOver20KAnnoLoader(
      argv
    );

    loader.loadLayer();
  },
};
