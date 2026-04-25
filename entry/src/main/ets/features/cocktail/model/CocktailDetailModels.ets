export interface CocktailFlavorMetricDto {
  sortOrder?: number;
  name?: string | null;
  value?: number | null;
}

export interface CocktailMaterialDto {
  materialId?: number;
  name?: string | null;
  category?: string | null;
  displayName?: string | null;
  amount?: string | null;
  note?: string | null;
  sortOrder?: number;
}

export interface CocktailStepDto {
  order?: number;
  title?: string | null;
  detail?: string | null;
}

export interface CocktailPageQuery {
  keyword?: string | null;
  page?: number;
  size?: number;
}

export interface CocktailCategoryDto {
  name: string;
  icon?: string | null;
}

export interface CocktailListItemDto {
  id: number;
  name: string;
  englishName?: string | null;
  category?: string | null;
  heroImage?: string | null;
  difficulty?: string | null;
  abv?: string | null;
  imageUrl?: string | null;
  imageUrlThumb?: string | null;
  imageUrlCard?: string | null;
  description?: string | null;
  alcoholLevel?: number | null;
}

export interface CocktailPageDto {
  content?: CocktailListItemDto[];
  totalElements?: number;
  totalPages?: number;
  number?: number;
  size?: number;
  first?: boolean;
  last?: boolean;
  numberOfElements?: number;
  empty?: boolean;
}

export interface CocktailDetailDto {
  id: number;
  name: string;
  englishName?: string | null;
  category?: string | null;
  heroImage?: string | null;
  difficulty?: string | null;
  abv?: string | null;
  glass?: string | null;
  garnish?: string | null;
  highlight?: string | null;
  subtitle?: string | null;
  description?: string | null;
  story?: string | null;
  imageUrl?: string | null;
  heroImageCard?: string | null;
  heroImageDetail?: string | null;
  alcoholLevel?: number | null;
  legacySteps?: string | null;
  flavorTags?: string[];
  flavorMetrics?: CocktailFlavorMetricDto[];
  pairings?: string[];
  serviceNotes?: string[];
  steps?: CocktailStepDto[];
  materials?: CocktailMaterialDto[];
  createdAt?: string | null;
}

function normalizeImageUrl(value?: string | null): string {
  return typeof value === 'string' ? value.trim() : '';
}

export function resolveCocktailListImage(item: CocktailListItemDto): string {
  const candidates: Array<string | null | undefined> = [
    item.imageUrlThumb,
    item.imageUrlCard,
    item.heroImage,
    item.imageUrl
  ];

  for (let index: number = 0; index < candidates.length; index += 1) {
    const candidate = normalizeImageUrl(candidates[index]);
    if (candidate.length > 0) {
      return candidate;
    }
  }

  return '';
}

export function resolveCocktailDetailHeroImage(item: CocktailDetailDto): string {
  const candidates: Array<string | null | undefined> = [
    item.heroImageCard,
    item.heroImageDetail,
    item.heroImage,
    item.imageUrl
  ];

  for (let index: number = 0; index < candidates.length; index += 1) {
    const candidate = normalizeImageUrl(candidates[index]);
    if (candidate.length > 0) {
      return candidate;
    }
  }

  return '';
}

export function resolveCocktailDetailPreviewImage(item: CocktailDetailDto): string {
  const candidates: Array<string | null | undefined> = [
    item.heroImageDetail,
    item.heroImageCard,
    item.heroImage,
    item.imageUrl
  ];

  for (let index: number = 0; index < candidates.length; index += 1) {
    const candidate = normalizeImageUrl(candidates[index]);
    if (candidate.length > 0) {
      return candidate;
    }
  }

  return '';
}
