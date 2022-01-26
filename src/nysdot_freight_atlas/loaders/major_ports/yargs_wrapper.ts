import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasMajorPortsLoader, {
  NysdotFreightAtlasMajorPortsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas MajorPorts layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas MajorPorts version (required format: YYYY).",
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

export const loadMajorPorts = {
  desc: "Load the MajorPorts layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_major_ports",
  builder,
  async handler(
    argv: NysdotFreightAtlasMajorPortsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasMajorPortsLoader(
      argv
    );

    loader.loadLayer();
  },
};
