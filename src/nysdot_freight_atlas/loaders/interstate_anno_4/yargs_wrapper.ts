import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasInterstateAnno4Loader, {
  NysdotFreightAtlasInterstateAnno4LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas InterstateAnno4 layer name.",
    demand: true,
    type: "string",
    default: "InterstateAnno4",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas InterstateAnno4 version (required format: YYYY).",
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

export const loadInterstateAnno4 = {
  desc: "Load the InterstateAnno4 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_interstate_anno_4",
  builder,
  async handler(
    argv: NysdotFreightAtlasInterstateAnno4LoaderParams
  ) {
    const loader = new NysdotFreightAtlasInterstateAnno4Loader(
      argv
    );

    loader.loadLayer();
  },
};
