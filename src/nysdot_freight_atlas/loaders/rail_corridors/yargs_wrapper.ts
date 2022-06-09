import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasRailCorridorsLoader, {
  NysdotFreightAtlasRailCorridorsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas RailCorridors layer name.",
    demand: true,
    type: "string",
    default: "RailCorridors",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas RailCorridors version (required format: YYYY).",
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

export const loadRailCorridors = {
  desc: "Load the RailCorridors layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_rail_corridors",
  builder,
  async handler(
    argv: NysdotFreightAtlasRailCorridorsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasRailCorridorsLoader(
      argv
    );

    loader.loadLayer();
  },
};
