import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasPipelineZonesLoader, {
  NysdotFreightAtlasPipelineZonesLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas PipelineZones layer name.",
    demand: true,
    type: "string",
    default: "PipelineZones",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas PipelineZones version (required format: YYYY).",
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

export const loadPipelineZones = {
  desc: "Load the PipelineZones layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_pipeline_zones",
  builder,
  async handler(
    argv: NysdotFreightAtlasPipelineZonesLoaderParams
  ) {
    const loader = new NysdotFreightAtlasPipelineZonesLoader(
      argv
    );

    loader.loadLayer();
  },
};
