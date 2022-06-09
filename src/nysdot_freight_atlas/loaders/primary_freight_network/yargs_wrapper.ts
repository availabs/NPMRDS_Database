import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasPrimaryFreightNetworkLoader, {
  NysdotFreightAtlasPrimaryFreightNetworkLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas PrimaryFreightNetwork layer name.",
    demand: true,
    type: "string",
    default: "Primary_Freight_Network",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas PrimaryFreightNetwork version (required format: YYYY).",
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

export const loadPrimaryFreightNetwork = {
  desc: "Load the PrimaryFreightNetwork layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_primary_freight_network",
  builder,
  async handler(
    argv: NysdotFreightAtlasPrimaryFreightNetworkLoaderParams
  ) {
    const loader = new NysdotFreightAtlasPrimaryFreightNetworkLoader(
      argv
    );

    loader.loadLayer();
  },
};
