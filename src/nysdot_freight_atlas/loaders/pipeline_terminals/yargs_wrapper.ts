import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasPipelineTerminalsLoader, {
  NysdotFreightAtlasPipelineTerminalsLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas PipelineTerminals layer name.",
    demand: true,
    type: "string",
    default: "Intermodal_Facility",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas PipelineTerminals version (required format: YYYY).",
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

export const loadPipelineTerminals = {
  desc: "Load the PipelineTerminals layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_pipeline_terminals",
  builder,
  async handler(
    argv: NysdotFreightAtlasPipelineTerminalsLoaderParams
  ) {
    const loader = new NysdotFreightAtlasPipelineTerminalsLoader(
      argv
    );

    loader.loadLayer();
  },
};
