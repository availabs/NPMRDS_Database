import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasBorderCrossingPortLoader, {
  NysdotFreightAtlasBorderCrossingPortLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas BorderCrossingPort layer name.",
    demand: true,
    type: "string",
    default: "Border_Crossing_Port",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas BorderCrossingPort version (required format: YYYY).",
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

export const loadBorderCrossingPort = {
  desc: "Load the BorderCrossingPort layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_border_crossing_port",
  builder,
  async handler(
    argv: NysdotFreightAtlasBorderCrossingPortLoaderParams
  ) {
    const loader = new NysdotFreightAtlasBorderCrossingPortLoader(
      argv
    );

    loader.loadLayer();
  },
};
