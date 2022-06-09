import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCanadaLoader, {
  NysdotFreightAtlasCanadaLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Canada layer name.",
    demand: true,
    type: "string",
    default: "Canada",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Canada version (required format: YYYY).",
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

export const loadCanada = {
  desc: "Load the Canada layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_canada",
  builder,
  async handler(
    argv: NysdotFreightAtlasCanadaLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCanadaLoader(
      argv
    );

    loader.loadLayer();
  },
};
