import NysdotFreightAtlasLayerLoaderBaseClass, {
  NysdotFreightAtlasLayerLoaderBaseClassParams,
} from "../../utils/NysdotFreightAtlasLayerLoaderBaseClass";

export type NysdotFreightAtlasPop20KCitiesResizeLoaderParams = {
  nysdot_freight_atlas_geodatabase_path: NysdotFreightAtlasLayerLoaderBaseClassParams["nysdot_freight_atlas_geodatabase_path"];
  geodatabase_layer_name: string;
  table_version: string;
  pg_env: NysdotFreightAtlasLayerLoaderBaseClassParams["pg_env"];
};

export default class NysdotFreightAtlasPop20KCitiesResizeLoader extends NysdotFreightAtlasLayerLoaderBaseClass {
  constructor({
    nysdot_freight_atlas_geodatabase_path,
    geodatabase_layer_name,
    table_version,
    pg_env,
  }: NysdotFreightAtlasPop20KCitiesResizeLoaderParams) {
    super({
      table_name_base: "pop_20k_cities_resize",
      nysdot_freight_atlas_geodatabase_path,
      table_version,
      geodatabase_layer_name,
      pg_env,
    });
  }
}
