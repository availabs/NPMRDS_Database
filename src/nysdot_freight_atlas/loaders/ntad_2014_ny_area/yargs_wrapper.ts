import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNtad2014NyAreaLoader, {
  NysdotFreightAtlasNtad2014NyAreaLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Ntad2014NyArea layer name.",
    demand: true,
    type: "string",
    default: "NTAD_2014_NYarea",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Ntad2014NyArea version (required format: YYYY).",
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

export const loadNtad2014NyArea = {
  desc: "Load the Ntad2014NyArea layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_ntad_2014_ny_area",
  builder,
  async handler(
    argv: NysdotFreightAtlasNtad2014NyAreaLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNtad2014NyAreaLoader(
      argv
    );

    loader.loadLayer();
  },
};
