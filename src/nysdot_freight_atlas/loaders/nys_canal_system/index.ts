import NysdotFreightAtlasLayerLoaderBaseClass, {
  NysdotFreightAtlasLayerLoaderBaseClassParams,
} from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

export type NysdotFreightAtlasNysCanalSystemLoaderParams = {
  nysdot_freight_atlas_geodatabase_path: NysdotFreightAtlasLayerLoaderBaseClassParams["nysdot_freight_atlas_geodatabase_path"];
  geodatabase_layer_name: string;
  table_version: string;
  pg_env: NysdotFreightAtlasLayerLoaderBaseClassParams["pg_env"];
};

export default class NysdotFreightAtlasNysCanalSystemLoader extends NysdotFreightAtlasLayerLoaderBaseClass {
  constructor({
    nysdot_freight_atlas_geodatabase_path,
    geodatabase_layer_name,
    table_version,
    pg_env,
  }: NysdotFreightAtlasNysCanalSystemLoaderParams) {
    super({
      table_name_base: "nys_canal_system",
      nysdot_freight_atlas_geodatabase_path,
      table_version,
      geodatabase_layer_name,
      pg_env,
    });
  }
}
