export interface InventoryTab {
  id: string;
  title: string;
}

export const INVENTORY_TABS: InventoryTab[] = [
  { id: 'all', title: '全部' },
  { id: 'base_liquor', title: '基底 / 酒类' },
  { id: 'fruit_flavor', title: '水果 / 调味' },
  { id: 'garnish_spice', title: '装饰 / 香料' }
];

export enum OwnershipFilterType {
  ALL = 'all',
  OWNED = 'owned',
  UNOWNED = 'unowned'
}
