import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasCentralRegionLoader, {
  NysdotFreightAtlasCentralRegionLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas CentralRegion layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas CentralRegion version (required format: YYYY).",
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

export const loadCentralRegion = {
  desc: "Load the CentralRegion layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_central_region",
  builder,
  async handler(
    argv: NysdotFreightAtlasCentralRegionLoaderParams
  ) {
    const loader = new NysdotFreightAtlasCentralRegionLoader(
      argv
    );

    loader.loadLayer();
  },
};
