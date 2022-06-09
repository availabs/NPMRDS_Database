import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMajorAirportsLoader, {
  NysdotFreightAtlasMajorAirportsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MajorAirports layer name.",
    demand: true,
    type: "string",
    default: "Major_Airport",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MajorAirports version (required format: YYYY).",
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

export const loadMajorAirports = {
  desc: "Load the MajorAirports layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_major_airports",
  builder,
  async handler(
    argv: NysdotFreightAtlasMajorAirportsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMajorAirportsLoader(
      argv
    );

    loader.loadLayer();
  },
};
