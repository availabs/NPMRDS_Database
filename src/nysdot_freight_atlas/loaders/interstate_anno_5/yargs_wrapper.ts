import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasInterstateAnno5Loader, {
  NysdotFreightAtlasInterstateAnno5LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas InterstateAnno5 layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas InterstateAnno5 version (required format: YYYY).",
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

export const loadInterstateAnno5 = {
  desc: "Load the InterstateAnno5 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_interstate_anno_5",
  builder,
  async handler(
    argv: NysdotFreightAtlasInterstateAnno5LoaderParams
  ) {
    const loader = new NysdotFreightAtlasInterstateAnno5Loader(
      argv
    );

    loader.loadLayer();
  },
};
