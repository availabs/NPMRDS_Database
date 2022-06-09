import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCanAdm1Loader, {
  NysdotFreightAtlasCanAdm1LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas CanAdm1 layer name.",
    demand: true,
    type: "string",
    default: "CAN_adm1",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas CanAdm1 version (required format: YYYY).",
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

export const loadCanAdm1 = {
  desc: "Load the CanAdm1 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_can_adm1",
  builder,
  async handler(
    argv: NysdotFreightAtlasCanAdm1LoaderParams
  ) {
    const loader = new NysdotFreightAtlasCanAdm1Loader(
      argv
    );

    loader.loadLayer();
  },
};
