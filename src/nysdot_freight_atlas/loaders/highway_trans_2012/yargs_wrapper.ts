import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasHighwayTrans2012Loader, {
  NysdotFreightAtlasHighwayTrans2012LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas HighwayTrans2012 layer name.",
    demand: true,
    type: "string",
    default: "HighwayTrans2012",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas HighwayTrans2012 version (required format: YYYY).",
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

export const loadHighwayTrans2012 = {
  desc: "Load the HighwayTrans2012 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_highway_trans_2012",
  builder,
  async handler(
    argv: NysdotFreightAtlasHighwayTrans2012LoaderParams
  ) {
    const loader = new NysdotFreightAtlasHighwayTrans2012Loader(
      argv
    );

    loader.loadLayer();
  },
};
