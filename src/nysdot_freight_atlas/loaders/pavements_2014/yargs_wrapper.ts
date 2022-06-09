import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasPavements2014Loader, {
  NysdotFreightAtlasPavements2014LoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Pavements2014 layer name.",
    demand: true,
    type: "string",
    default: "Pavements2014",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Pavements2014 version (required format: YYYY).",
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

export const loadPavements2014 = {
  desc: "Load the Pavements2014 layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_pavements_2014",
  builder,
  async handler(
    argv: NysdotFreightAtlasPavements2014LoaderParams
  ) {
    const loader = new NysdotFreightAtlasPavements2014Loader(
      argv
    );

    loader.loadLayer();
  },
};
