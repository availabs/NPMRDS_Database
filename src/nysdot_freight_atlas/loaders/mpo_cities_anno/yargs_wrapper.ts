import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMpoCitiesAnnoLoader, {
  NysdotFreightAtlasMpoCitiesAnnoLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MpoCitiesAnno layer name.",
    demand: true,
    type: "string",
    default: "MPO_Cities_Anno",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MpoCitiesAnno version (required format: YYYY).",
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

export const loadMpoCitiesAnno = {
  desc: "Load the MpoCitiesAnno layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_mpo_cities_anno",
  builder,
  async handler(
    argv: NysdotFreightAtlasMpoCitiesAnnoLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMpoCitiesAnnoLoader(
      argv
    );

    loader.loadLayer();
  },
};
