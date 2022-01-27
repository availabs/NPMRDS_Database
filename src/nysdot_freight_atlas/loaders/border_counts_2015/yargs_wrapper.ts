import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasBorderCounts2015Loader, {
  NysdotFreightAtlasBorderCounts2015LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas BorderCounts2015 layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas BorderCounts2015 version (required format: YYYY).",
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

export const loadBorderCounts2015 = {
  desc: "Load the BorderCounts2015 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_border_counts_2015",
  builder,
  async handler(
    argv: NysdotFreightAtlasBorderCounts2015LoaderParams
  ) {
    const loader = new NysdotFreightAtlasBorderCounts2015Loader(
      argv
    );

    loader.loadLayer();
  },
};
