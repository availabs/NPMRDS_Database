import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasHighwayTrans2040Loader, {
  NysdotFreightAtlasHighwayTrans2040LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas HighwayTrans2040 layer name.",
    demand: true,
    type: "string",
    default: "HighwayTrans2040",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas HighwayTrans2040 version (required format: YYYY).",
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

export const loadHighwayTrans2040 = {
  desc: "Load the HighwayTrans2040 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_highway_trans_2040",
  builder,
  async handler(
    argv: NysdotFreightAtlasHighwayTrans2040LoaderParams
  ) {
    const loader = new NysdotFreightAtlasHighwayTrans2040Loader(
      argv
    );

    loader.loadLayer();
  },
};
