import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasPipelinesLoader, {
  NysdotFreightAtlasPipelinesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Pipelines layer name.",
    demand: true,
    type: "string",
    default: "Pipelines",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Pipelines version (required format: YYYY).",
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

export const loadPipelines = {
  desc: "Load the Pipelines layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_pipelines",
  builder,
  async handler(
    argv: NysdotFreightAtlasPipelinesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasPipelinesLoader(
      argv
    );

    loader.loadLayer();
  },
};
