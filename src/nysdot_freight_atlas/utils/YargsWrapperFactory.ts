import { PGEnv } from "../utils/NysdotFreightAtlasLayerLoaderBaseClass";

export default class YargsWrapperFactory {
  static createYargsWrapperForNysdotFreightAtlasLayerLoader(LoaderClass: any) {
    const { table_base_name } = LoaderClass;

    const builder = {
      nysdot_freight_atlas_geodatabase_path: {
        desc: "Path to the NYSDOT FreightAtlas GeoDatabase",
        demand: true,
        type: "string",
      },

      [`${table_base_name}_layer_name`]: {
        desc: "NYSDOT FreightAtlas BorderCrossingPorts layer name.",
        demand: true,
        type: "string",
      },
      [`${table_base_name}_version`]: {
        desc: "NYSDOT FreightAtlas BorderCrossingPorts version (required format: YYYY).",
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

    return {
      desc: "Load the BorderCrossingPorts layer from the NYSDOT FreightAtlas GeoDatabase",
      command: "load_nysdot_freight_atlas_border_crossing_ports",
      builder,
      async handler(argv: any) {
        const loader = new LoaderClass(argv);

        loader.loadLayer();
      },
    };
  }
}
