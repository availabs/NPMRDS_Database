import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasNhpnLoader, {
  NysdotFreightAtlasNhpnLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas Nhpn layer name.",
    demand: true,
    type: "string",
    default: "NHPN",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas Nhpn version (required format: YYYY).",
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

export const loadNhpn = {
  desc: "Load the Nhpn layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_nhpn",
  builder,
  async handler(
    argv: NysdotFreightAtlasNhpnLoaderParams
  ) {
    const loader = new NysdotFreightAtlasNhpnLoader(
      argv
    );

    loader.loadLayer();
  },
};
