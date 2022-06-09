import { PGEnv } from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

import NysdotFreightAtlasTruckParkingLoader, {
  NysdotFreightAtlasTruckParkingLoaderParams,
} from ".";

const builder = {
  nysdot_freight_atlas_geodatabase_path: {
    desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
    demand: true,
    type: "string",
  },
  geodatabase_layer_name: {
    desc: "NYSDOT FreightAtlas TruckParking layer name.",
    demand: true,
    type: "string",
    default: "TruckParking",
  },
  table_version: {
    desc: "NYSDOT FreightAtlas TruckParking version (required format: YYYY).",
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

export const loadTruckParking = {
  desc: "Load the TruckParking layer from the NYSDOT FreightAtlas GeoDatabase",
  command: "load_nysdot_freight_atlas_truck_parking",
  builder,
  async handler(
    argv: NysdotFreightAtlasTruckParkingLoaderParams
  ) {
    const loader = new NysdotFreightAtlasTruckParkingLoader(
      argv
    );

    loader.loadLayer();
  },
};
