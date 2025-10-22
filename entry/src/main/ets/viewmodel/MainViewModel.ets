import ItemData from './ItemData';

export class MainViewModel {
  getSettingListData(): Array<ItemData> {
    let settingListData: ItemData[] = [
      new ItemData($r('app.string.setting_list_news'), $r('app.media.news'), $r('app.string.setting_list_menu')),
      new ItemData($r('app.string.setting_list_data'), $r('app.media.data'),$r(null)),
      new ItemData($r('app.string.setting_list_menu'), $r('app.media.menu'),$r(null)),
    ];
    return settingListData;
  }
  /*
   * Get data of the first grid
   */
  getFirstGirdData(): Array<ItemData> {
    let firstGirdData:ItemData[] = [
      new ItemData($r('app.string.my_cocktail'),$r('app.media.my_cocktail')),
      new ItemData($r('app.string.material_selection'),$r('app.media.material_selection')),
      new ItemData($r('app.string.favorite_recipes'),$r('app.media.favorite_recipes')),
      new ItemData($r('app.string.classic_formula'),$r('app.media.classic_formula')),
      new ItemData($r('app.string.friend'),$r('app.media.friend')),
      new ItemData($r('app.string.discontinued_formulas'),$r('app.media.discontinued_formulas'))
    ];
    return firstGirdData;
  }

  /*
   * Get swiper image data
   */
  getSwiperImages(): Array<Resource> {
    let swiperImages: Resource[] = [
      $r('app.media.fig1'),
      $r('app.media.fig2'),
      $r('app.media.fig3'),
      $r('app.media.fig4')
    ];
    return swiperImages;
  }

  /*
   * Get data of the second grid.
   *
   */
  getSecondGridData(): Array<ItemData>{
    let secondGridData: ItemData[] = [
      new ItemData($r('app.string.the_unforgettable'),$r('app.media.dry_martini'),$r('app.string.dry_martini')),
      new ItemData($r('app.string.contemporary_classics'),$r('app.media.zombie'),$r('app.string.zombie')),
      new ItemData($r('app.string.new_era_drink'),$r('app.media.paloma'),$r('app.string.paloma')),
    ]
    return secondGridData;
  }

}
export default new MainViewModel();