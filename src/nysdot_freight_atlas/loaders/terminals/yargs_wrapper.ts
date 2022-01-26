import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasTerminalsLoader, {
  NysdotFreightAtlasTerminalsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Terminals layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Terminals version (required format: YYYY).",
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

export const loadTerminals = {
  desc: "Load the Terminals layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_terminals",
  builder,
  async handler(
    argv: NysdotFreightAtlasTerminalsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasTerminalsLoader(
      argv
    );

    loader.loadLayer();
  },
};
