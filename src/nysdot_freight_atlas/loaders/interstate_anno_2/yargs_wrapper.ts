import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasInterstateAnno2Loader, {
  NysdotFreightAtlasInterstateAnno2LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas InterstateAnno2 layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas InterstateAnno2 version (required format: YYYY).",
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

export const loadInterstateAnno2 = {
  desc: "Load the InterstateAnno2 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_interstate_anno_2",
  builder,
  async handler(
    argv: NysdotFreightAtlasInterstateAnno2LoaderParams
  ) {
    const loader = new NysdotFreightAtlasInterstateAnno2Loader(
      argv
    );

    loader.loadLayer();
  },
};
