import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCommuterIcpLoader, {
  NysdotFreightAtlasCommuterIcpLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas CommuterIcp layer name.",
    demand: true,
    type: "string",
    default: "CommuterICP",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas CommuterIcp version (required format: YYYY).",
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

export const loadCommuterIcp = {
  desc: "Load the CommuterIcp layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_commuter_icp",
  builder,
  async handler(
    argv: NysdotFreightAtlasCommuterIcpLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCommuterIcpLoader(
      argv
    );

    loader.loadLayer();
  },
};
