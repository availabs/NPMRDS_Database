import NysdotFreightAtlasLayerLoaderBaseClass, {
  NysdotFreightAtlasLayerLoaderBaseClassParams,
} from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

export type NysdotFreightAtlasCentralRegionLoaderParams = {
  nysdot_freight_atlas_geodatabase_path: NysdotFreightAtlasLayerLoaderBaseClassParams["nysdot_freight_atlas_geodatabase_path"];
  geodatabase_layer_name: string;
  table_version: string;
  pg_env: NysdotFreightAtlasLayerLoaderBaseClassParams["pg_env"];
};

export default class NysdotFreightAtlasCentralRegionLoader extends NysdotFreightAtlasLayerLoaderBaseClass {
  constructor({
    nysdot_freight_atlas_geodatabase_path,
    geodatabase_layer_name,
    table_version,
    pg_env,
  }: NysdotFreightAtlasCentralRegionLoaderParams) {
    super({
      table_name_base: "central_region",
      nysdot_freight_atlas_geodatabase_path,
      table_version,
      geodatabase_layer_name,
      pg_env,
    });
  }
}
