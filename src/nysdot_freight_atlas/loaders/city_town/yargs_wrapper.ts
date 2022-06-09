import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCityTownLoader, {
  NysdotFreightAtlasCityTownLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas CityTown layer name.",
    demand: true,
    type: "string",
    default: "City_Town",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas CityTown version (required format: YYYY).",
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

export const loadCityTown = {
  desc: "Load the CityTown layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_city_town",
  builder,
  async handler(
    argv: NysdotFreightAtlasCityTownLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCityTownLoader(
      argv
    );

    loader.loadLayer();
  },
};
