
import { MaterialPreviewImageSource } from '../../../common/components/MaterialImagePreviewOverlay';

export interface StationStat {
  id: string;
  value: string;
  label: string;
  detail: string;
  accentColor: string;
  softColor: string;
}

export interface StationAction {
  id: string;
  title: string;
  detail: string;
  badge: string;
  actionText: string;
  accentColor: string;
  softColor: string;
  route: string;
}

export interface MaterialCategory {
  id: string;
  title: string;
  detail: string;
  countText: string;
  pendingText: string;
  badge: string;
  accentColor: string;
  softColor: string;
  previewItems: string[];
}
export interface MaterialRecord extends MaterialPreviewImageSource {
  id: string;
  name: string;
  subtitle: string;
  categoryId: string;
  categoryName: string;
  barcode?: string;
  addedAt?: string;
  amountText: string;
  statusText: string;
  needsCompletion: boolean;
  badge: string;
  accentColor: string;
  softColor: string;
  tags: string[];
}

export interface SelectableMaterial {
  id: string;
  materialId?: number;
  name: string;
  imageUrl?: string;
  imageUrlThumb?: string;
  imageUrlCard?: string;
  imageUrlDetail?: string;
  description?: string;
  subtitle: string;
  categoryId: string;
  categoryName: string;
  quickNote: string;
  badge: string;
  accentColor: string;
  softColor: string;
  tags: string[];
  isCommon: boolean;
  isRecent: boolean;
  isRecommended: boolean;
}
export interface MaterialDraft extends MaterialPreviewImageSource {
  id: string;
  source: string;
  sourceLabel: string;
  name: string;
  subtitle: string;
  brand: string;
  categoryId: string;
  barcode: string;
  addedAt?: string;
  materialId?: number;
  capacityText: string;
  remainLevel: string;
  opened: boolean;
  hasItem: boolean;
  tags: string[];
  note: string;
  badge: string;
  accentColor: string;
  softColor: string;
}

export interface FilterTab {
  id: string;
  title: string;
}

export interface MaterialListCategory {
  id: string;
  title: string;
}

export const STATION_ACTIONS: StationAction[] = [
  {
    id: 'scan',
    title: '扫描酒瓶条码',
    detail: '适合录入基酒、利口酒和已有包装的材料，先扫再补信息。',
    badge: 'SCAN',
    actionText: '立即扫描',
    accentColor: '#1B596E',
    softColor: '#DDF5F1',
    route: 'features/station/pages/MaterialScannerPage'
  },
  {
    id: 'library',
    title: '从列表选择材料',
    detail: '水果、软饮、糖浆和杯具更适合直接挑选，录入速度更快。',
    badge: 'LIST',
    actionText: '打开列表',
    accentColor: '#245C82',
    softColor: '#E8F5FB',
    route: 'features/station/pages/MaterialLibraryPage'
  }
];

export const STATION_STATS: StationStat[] = [
  {
    id: 'materials',
    value: '28',
    label: '已录入材料',
    detail: '覆盖 6 类常用配方原料',
    accentColor: '#1B596E',
    softColor: '#DDF5F1'
  },
  {
    id: 'pending',
    value: '5',
    label: '待补全信息',
    detail: '建议先完善容量和风味标签',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF'
  },
  {
    id: 'recipe',
    value: '16',
    label: '可匹配酒谱',
    detail: '比上周多 4 款可执行方案',
    accentColor: '#245C82',
    softColor: '#E8F5FB'
  }
];

export const MATERIAL_CATEGORIES: MaterialCategory[] = [
  {
    id: 'spirit',
    title: '基酒区',
    detail: '优先录入金酒、朗姆、伏特加、威士忌。',
    countText: '8 瓶',
    pendingText: '2 项待补全',
    badge: 'SP',
    accentColor: '#1B596E',
    softColor: '#DDF5F1',
    previewItems: ['亨利爵士金酒', '百加得白朗姆', '绝对伏特加']
  },
  {
    id: 'liqueur',
    title: '风味酒区',
    detail: '苦味酒、橙酒和甜味酒会直接影响推荐结果。',
    countText: '6 瓶',
    pendingText: '1 项待补全',
    badge: 'LQ',
    accentColor: '#245C82',
    softColor: '#E8F5FB',
    previewItems: ['金巴利', '君度', '马天尼味美思']
  },
  {
    id: 'mixer',
    title: '软饮与糖浆',
    detail: '适合快速从列表补齐，避免手动输入。',
    countText: '9 项',
    pendingText: '1 项待补全',
    badge: 'MX',
    accentColor: '#2B6C63',
    softColor: '#DDF5F1',
    previewItems: ['汤力水', '苏打水', '红石榴糖浆']
  },
  {
    id: 'fruit',
    title: '水果与装饰',
    detail: '柠檬、青柠、薄荷和果皮建议常备。',
    countText: '11 项',
    pendingText: '0 项待补全',
    badge: 'FR',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF',
    previewItems: ['青柠', '柠檬', '迷迭香']
  },
  {
    id: 'glassware',
    title: '杯具与工具',
    detail: '补充杯型后，出杯建议会更准确。',
    countText: '4 项',
    pendingText: '1 项待补全',
    badge: 'GW',
    accentColor: '#3F5D75',
    softColor: '#EAF1F6',
    previewItems: ['Highball 杯', 'Coupe 杯', '量酒器']
  }
];

export const PENDING_MATERIALS: MaterialRecord[] = [
  {
    id: 'hendricks-gin',
    name: '亨利爵士金酒',
    subtitle: '条码识别后还缺容量与开封状态',
    categoryId: 'spirit',
    categoryName: '基酒',
    amountText: '容量待补充',
    statusText: '待补全',
    needsCompletion: true,
    badge: 'HG',
    accentColor: '#1B596E',
    softColor: '#DDF5F1',
    tags: ['草本', '杜松子']
  },
  {
    id: 'campari',
    name: '金巴利',
    subtitle: '已识别品牌，建议补充风味标签',
    categoryId: 'liqueur',
    categoryName: '风味酒',
    amountText: '剩余约 60%',
    statusText: '待补全',
    needsCompletion: true,
    badge: 'CP',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF',
    tags: ['苦味', '橙皮']
  }
];

export const RECENT_MATERIALS: MaterialRecord[] = [
  {
    id: 'bacardi-rum',
    name: '百加得白朗姆',
    subtitle: '最近添加 · 可匹配 Daiquiri、Mojito',
    categoryId: 'spirit',
    categoryName: '基酒',
    amountText: '剩余约 72%',
    statusText: '常备',
    needsCompletion: false,
    badge: 'BR',
    accentColor: '#1B596E',
    softColor: '#DDF5F1',
    tags: ['清爽', '白朗姆']
  },
  {
    id: 'tonic-water',
    name: '汤力水',
    subtitle: '最近添加 · 适合 Highball 与 Gin Tonic',
    categoryId: 'mixer',
    categoryName: '软饮',
    amountText: '6 瓶未开封',
    statusText: '已补全',
    needsCompletion: false,
    badge: 'TW',
    accentColor: '#245C82',
    softColor: '#E8F5FB',
    tags: ['气泡', '常用']
  },
  {
    id: 'lime',
    name: '青柠',
    subtitle: '最近添加 · 建议补货提醒设为 4 颗',
    categoryId: 'fruit',
    categoryName: '水果',
    amountText: '库存 6 颗',
    statusText: '新加入',
    needsCompletion: false,
    badge: 'LM',
    accentColor: '#2B6C63',
    softColor: '#DDF5F1',
    tags: ['酸感', '装饰']
  },
  {
    id: 'highball-glass',
    name: 'Highball 杯',
    subtitle: '最近添加 · 可优化出杯推荐',
    categoryId: 'glassware',
    categoryName: '杯具',
    amountText: '6 只可用',
    statusText: '已补全',
    needsCompletion: false,
    badge: 'HB',
    accentColor: '#3F5D75',
    softColor: '#EAF1F6',
    tags: ['高杯', '直身']
  }
];

export const RECORDED_MATERIALS: MaterialRecord[] = [
  PENDING_MATERIALS[0],
  RECENT_MATERIALS[0],
  PENDING_MATERIALS[1],
  RECENT_MATERIALS[1],
  RECENT_MATERIALS[2],
  RECENT_MATERIALS[3]
];

export const MATERIAL_LIST_CATEGORIES: MaterialListCategory[] = [
  { id: 'all', title: '全部' },
  { id: 'spirit', title: '基酒' },
  { id: 'liqueur', title: '风味酒' },
  { id: 'mixer', title: '软饮 / 糖浆' },
  { id: 'fruit', title: '水果' },
  { id: 'glassware', title: '杯具' }
];

export const LIBRARY_FILTERS: FilterTab[] = [
  { id: 'fruit', title: '水果' },
  { id: 'soft_drink', title: '软饮' },
  { id: 'syrup', title: '糖浆' },
  { id: 'glassware', title: '杯具' }
];

export const LIBRARY_ITEMS: SelectableMaterial[] = [
  {
    id: 'hendricks-gin',
    name: '亨利爵士金酒',
    subtitle: '杜松子、黄瓜与玫瑰风味',
    categoryId: 'spirit',
    categoryName: '基酒',
    quickNote: '适合经典清爽型酒谱',
    badge: 'HG',
    accentColor: '#1B596E',
    softColor: '#DDF5F1',
    tags: ['常用', '草本'],
    isCommon: true,
    isRecent: false,
    isRecommended: true
  },
  {
    id: 'bacardi-rum',
    name: '百加得白朗姆',
    subtitle: '白朗姆基础款，适合高频入门酒谱',
    categoryId: 'spirit',
    categoryName: '基酒',
    quickNote: 'Daiquiri、Mojito 常用',
    badge: 'BR',
    accentColor: '#1B596E',
    softColor: '#DDF5F1',
    tags: ['清爽', '常备'],
    isCommon: true,
    isRecent: true,
    isRecommended: true
  },
  {
    id: 'campari',
    name: '金巴利',
    subtitle: '苦味酒，适合 Negroni 等经典结构',
    categoryId: 'liqueur',
    categoryName: '风味酒',
    quickNote: '补齐后推荐层次更丰富',
    badge: 'CP',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF',
    tags: ['苦味', '橙皮'],
    isCommon: true,
    isRecent: true,
    isRecommended: true
  },
  {
    id: 'cointreau',
    name: '君度橙酒',
    subtitle: '橙香利口酒，适合 Margarita 与 Sidecar',
    categoryId: 'liqueur',
    categoryName: '风味酒',
    quickNote: '是很多酸甜结构的桥梁材料',
    badge: 'CT',
    accentColor: '#245C82',
    softColor: '#E8F5FB',
    tags: ['橙香', '常用'],
    isCommon: true,
    isRecent: false,
    isRecommended: true
  },
  {
    id: 'tonic-water',
    name: '汤力水',
    subtitle: '常见气泡软饮，适合 Highball 类酒谱',
    categoryId: 'mixer',
    categoryName: '软饮',
    quickNote: '建议一次录入整箱库存',
    badge: 'TW',
    accentColor: '#245C82',
    softColor: '#E8F5FB',
    tags: ['气泡', '高频'],
    isCommon: true,
    isRecent: true,
    isRecommended: true
  },
  {
    id: 'soda-water',
    name: '苏打水',
    subtitle: '用于拉长口感与提升清爽度',
    categoryId: 'mixer',
    categoryName: '软饮',
    quickNote: '常见于 Collins 与 Spritz',
    badge: 'SW',
    accentColor: '#245C82',
    softColor: '#E8F5FB',
    tags: ['清爽', '常用'],
    isCommon: true,
    isRecent: false,
    isRecommended: false
  },
  {
    id: 'grenadine',
    name: '红石榴糖浆',
    subtitle: '色彩明显，适合热带风格酒谱',
    categoryId: 'mixer',
    categoryName: '糖浆',
    quickNote: '录入后记得补充甜度标签',
    badge: 'GR',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF',
    tags: ['糖浆', '甜感'],
    isCommon: false,
    isRecent: false,
    isRecommended: true
  },
  {
    id: 'lime',
    name: '青柠',
    subtitle: '高频鲜果，适合酸感与装饰',
    categoryId: 'fruit',
    categoryName: '水果',
    quickNote: '建议同步记录补货阈值',
    badge: 'LM',
    accentColor: '#2B6C63',
    softColor: '#DDF5F1',
    tags: ['酸感', '装饰'],
    isCommon: true,
    isRecent: true,
    isRecommended: true
  },
  {
    id: 'lemon',
    name: '柠檬',
    subtitle: '适合 sour 风格和杯口处理',
    categoryId: 'fruit',
    categoryName: '水果',
    quickNote: '与青柠一起录入更完整',
    badge: 'LE',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF',
    tags: ['明亮', '常用'],
    isCommon: true,
    isRecent: false,
    isRecommended: true
  },
  {
    id: 'mint',
    name: '薄荷',
    subtitle: '用于 Mojito 与清新香气点缀',
    categoryId: 'fruit',
    categoryName: '装饰',
    quickNote: '库存变化快，建议快速记录',
    badge: 'MT',
    accentColor: '#2B6C63',
    softColor: '#DDF5F1',
    tags: ['清新', '香草'],
    isCommon: true,
    isRecent: true,
    isRecommended: false
  },
  {
    id: 'highball-glass',
    name: 'Highball 杯',
    subtitle: '适合长饮和气泡风格出杯',
    categoryId: 'glassware',
    categoryName: '杯具',
    quickNote: '补充杯型后推荐更准确',
    badge: 'HB',
    accentColor: '#3F5D75',
    softColor: '#EAF1F6',
    tags: ['高杯', '直身'],
    isCommon: true,
    isRecent: true,
    isRecommended: true
  },
  {
    id: 'coupe-glass',
    name: 'Coupe 杯',
    subtitle: '适合经典短饮和精致呈现',
    categoryId: 'glassware',
    categoryName: '杯具',
    quickNote: '与 Martini 杯搭配录入更完整',
    badge: 'CP',
    accentColor: '#3F5D75',
    softColor: '#EAF1F6',
    tags: ['短饮', '经典'],
    isCommon: false,
    isRecent: false,
    isRecommended: true
  }
];

const MATERIAL_DRAFTS: MaterialDraft[] = [
  {
    id: 'hendricks-gin',
    source: 'scan',
    sourceLabel: '条码识别结果',
    name: '亨利爵士金酒',
    subtitle: '已识别品牌与类别，建议补容量与开封状态。',
    brand: 'Hendrick\'s',
    categoryId: 'spirit',
    barcode: '5010327755017',
    capacityText: '700ml',
    remainLevel: '2/3',
    opened: true,
    hasItem: true,
    tags: ['杜松子', '草本', '黄瓜'],
    note: '适合用于 Gin Tonic、Southside 等清爽型配方。',
    badge: 'HG',
    accentColor: '#1B596E',
    softColor: '#DDF5F1'
  },
  {
    id: 'bacardi-rum',
    source: 'scan',
    sourceLabel: '材料台记录',
    name: '百加得白朗姆',
    subtitle: '高频基础酒，建议保持常备状态。',
    brand: 'Bacardi',
    categoryId: 'spirit',
    barcode: '7610113000152',
    capacityText: '750ml',
    remainLevel: '2/3',
    opened: true,
    hasItem: true,
    tags: ['白朗姆', '清爽', '常备'],
    note: '适合 Daiquiri、Mojito 和其他热带风格酒谱。',
    badge: 'BR',
    accentColor: '#1B596E',
    softColor: '#DDF5F1'
  },
  {
    id: 'campari',
    source: 'scan',
    sourceLabel: '条码识别结果',
    name: '金巴利',
    subtitle: '识别已完成，建议补充风味标签和剩余量。',
    brand: 'Campari',
    categoryId: 'liqueur',
    barcode: '8000040000800',
    capacityText: '750ml',
    remainLevel: '1/3',
    opened: true,
    hasItem: true,
    tags: ['苦味', '橙皮'],
    note: '适合 Negroni、Boulevardier 等经典苦味结构。',
    badge: 'CP',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF'
  },
  {
    id: 'cointreau',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '君度橙酒',
    subtitle: '从风味酒列表加入，建议补充剩余量。',
    brand: 'Cointreau',
    categoryId: 'liqueur',
    barcode: '3035542001001',
    capacityText: '700ml',
    remainLevel: '满瓶',
    opened: false,
    hasItem: true,
    tags: ['橙香', '甜苦平衡'],
    note: '酸甜型经典配方里的高频桥梁材料。',
    badge: 'CT',
    accentColor: '#245C82',
    softColor: '#E8F5FB'
  },
  {
    id: 'tonic-water',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '汤力水',
    subtitle: '建议按整瓶或整箱记录库存。',
    brand: 'Fever-Tree',
    categoryId: 'mixer',
    barcode: '5060108450005',
    capacityText: '200ml x 6',
    remainLevel: '满瓶',
    opened: false,
    hasItem: true,
    tags: ['气泡', '清爽', '高频'],
    note: '与金酒搭配最常用，也适合轻量 long drink。',
    badge: 'TW',
    accentColor: '#245C82',
    softColor: '#E8F5FB'
  },
  {
    id: 'soda-water',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '苏打水',
    subtitle: '适合长饮和稀释结构。',
    brand: 'Schweppes',
    categoryId: 'mixer',
    barcode: '6901234500012',
    capacityText: '330ml x 6',
    remainLevel: '满瓶',
    opened: false,
    hasItem: true,
    tags: ['气泡', '长饮'],
    note: '适合 Collins、Highball 和清爽低酒精结构。',
    badge: 'SW',
    accentColor: '#245C82',
    softColor: '#E8F5FB'
  },
  {
    id: 'grenadine',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '红石榴糖浆',
    subtitle: '适合热带调性和增加色彩层次。',
    brand: 'Monin',
    categoryId: 'mixer',
    barcode: '3052910052288',
    capacityText: '700ml',
    remainLevel: '满瓶',
    opened: false,
    hasItem: true,
    tags: ['糖浆', '甜感', '果香'],
    note: '建议补充甜度强度，方便后续配方推荐。',
    badge: 'GR',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF'
  },
  {
    id: 'lime',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '青柠',
    subtitle: '适合鲜果管理，可记录颗数和补货阈值。',
    brand: '鲜果材料',
    categoryId: 'fruit',
    barcode: '-',
    capacityText: '6 颗',
    remainLevel: '2/3',
    opened: true,
    hasItem: true,
    tags: ['酸感', '装饰'],
    note: '建议和柠檬一起录入，后续推荐会更完整。',
    badge: 'LM',
    accentColor: '#2B6C63',
    softColor: '#DDF5F1'
  },
  {
    id: 'lemon',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '柠檬',
    subtitle: '适合杯口处理、点缀与酸感来源。',
    brand: '鲜果材料',
    categoryId: 'fruit',
    barcode: '-',
    capacityText: '4 颗',
    remainLevel: '1/3',
    opened: true,
    hasItem: true,
    tags: ['明亮', '酸感'],
    note: '杯口处理和 garnish 都会用到。',
    badge: 'LE',
    accentColor: '#A66A1C',
    softColor: '#F8E9CF'
  },
  {
    id: 'mint',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: '薄荷',
    subtitle: '新鲜香草类，建议录入补货频率。',
    brand: '鲜果材料',
    categoryId: 'fruit',
    barcode: '-',
    capacityText: '1 束',
    remainLevel: '1/3',
    opened: true,
    hasItem: true,
    tags: ['清新', '香草'],
    note: '适合 Mojito 这类新鲜草本风格酒谱。',
    badge: 'MT',
    accentColor: '#2B6C63',
    softColor: '#DDF5F1'
  },
  {
    id: 'highball-glass',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: 'Highball 杯',
    subtitle: '录入杯具后，出杯推荐更准确。',
    brand: '杯具',
    categoryId: 'glassware',
    barcode: '-',
    capacityText: '6 只',
    remainLevel: '满瓶',
    opened: false,
    hasItem: true,
    tags: ['高杯', '直身'],
    note: '适合 Gin Tonic、Mojito 与其他气泡长饮。',
    badge: 'HB',
    accentColor: '#3F5D75',
    softColor: '#EAF1F6'
  },
  {
    id: 'coupe-glass',
    source: 'library',
    sourceLabel: '列表选择结果',
    name: 'Coupe 杯',
    subtitle: '适合精致短饮呈现。',
    brand: '杯具',
    categoryId: 'glassware',
    barcode: '-',
    capacityText: '4 只',
    remainLevel: '2/3',
    opened: false,
    hasItem: true,
    tags: ['短饮', '经典'],
    note: '适合许多 shaken and strained 的经典酒谱。',
    badge: 'CP',
    accentColor: '#3F5D75',
    softColor: '#EAF1F6'
  }
];

export function getCategoryTitle(categoryId: string): string {
  const category: MaterialCategory | undefined = MATERIAL_CATEGORIES.find((item: MaterialCategory): boolean => item.id === categoryId);
  if (category) {
    return category.title;
  }
  return '材料';
}

export function getDraftById(materialId?: string): MaterialDraft {
  const draft: MaterialDraft | undefined = MATERIAL_DRAFTS.find((item: MaterialDraft): boolean => item.id === materialId);
  if (draft) {
    return {
      id: draft.id,
      source: draft.source,
      sourceLabel: draft.sourceLabel,
      name: draft.name,
      subtitle: draft.subtitle,
      brand: draft.brand,
      categoryId: draft.categoryId,
      imageUrl: draft.imageUrl,
      imageUrlThumb: draft.imageUrlThumb,
      imageUrlCard: draft.imageUrlCard,
      imageUrlDetail: draft.imageUrlDetail,
      barcode: draft.barcode,
      addedAt: draft.addedAt,
      materialId: draft.materialId,
      capacityText: draft.capacityText,
      remainLevel: draft.remainLevel,
      opened: draft.opened,
      hasItem: draft.hasItem,
      tags: draft.tags.slice(),
      note: draft.note,
      badge: draft.badge,
      accentColor: draft.accentColor,
      softColor: draft.softColor
    };
  }

  return {
    id: 'new-material',
    source: 'manual',
    sourceLabel: '手动录入',
    name: '未命名材料',
    subtitle: '先收进材料台，再逐步补充信息。',
    brand: '未填写',
    categoryId: 'spirit',
    imageUrl: undefined,
    imageUrlThumb: undefined,
    imageUrlCard: undefined,
    imageUrlDetail: undefined,
    barcode: '-',
    addedAt: undefined,
    capacityText: '700ml',
    remainLevel: '满瓶',
    opened: false,
    hasItem: true,
    tags: ['待整理'],
    note: '这是一个前端写死的默认材料草稿。',
    badge: 'NM',
    accentColor: '#1B596E',
    softColor: '#DDF5F1'
  };
}
