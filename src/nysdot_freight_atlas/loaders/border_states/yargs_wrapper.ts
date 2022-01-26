import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasBorderStatesLoader, {
  NysdotFreightAtlasBorderStatesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas BorderStates layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas BorderStates version (required format: YYYY).",
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

export const loadBorderStates = {
  desc: "Load the BorderStates layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_border_states",
  builder,
  async handler(
    argv: NysdotFreightAtlasBorderStatesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasBorderStatesLoader(
      argv
    );

    loader.loadLayer();
  },
};
