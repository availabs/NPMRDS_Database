import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasInterstateAnnoLoader, {
  NysdotFreightAtlasInterstateAnnoLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas InterstateAnno layer name.",
    demand: true,
    type: "string",
    default: "InterstateAnno",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas InterstateAnno version (required format: YYYY).",
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

export const loadInterstateAnno = {
  desc: "Load the InterstateAnno layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_interstate_anno",
  builder,
  async handler(
    argv: NysdotFreightAtlasInterstateAnnoLoaderParams
  ) {
    const loader = new NysdotFreightAtlasInterstateAnnoLoader(
      argv
    );

    loader.loadLayer();
  },
};
