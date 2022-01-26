import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNhd24KwbANyLoader, {
  NysdotFreightAtlasNhd24KwbANyLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Nhd24KwbANy layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Nhd24KwbANy version (required format: YYYY).",
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

export const loadNhd24KwbANy = {
  desc: "Load the Nhd24KwbANy layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_nhd24kwb_a_ny",
  builder,
  async handler(
    argv: NysdotFreightAtlasNhd24KwbANyLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNhd24KwbANyLoader(
      argv
    );

    loader.loadLayer();
  },
};
