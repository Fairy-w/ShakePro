import { buildPublicAssetUrl } from '../../../common/constants/ApiConfig';
import { CocktailListItemDto } from './CocktailDetailModels';

export interface RecommendCocktailRequest {
  seedId: number;
  topk?: number;
  offset?: number;
}

export interface RecommendCocktailCodeStatusDto {
  indexSize?: number;
  indexDim?: number;
  semIdDim?: number;
  decoderEnabled?: boolean;
  decoderReason?: string | null;
  device?: string | null;
  backendFallback?: boolean;
  backendMessage?: string | null;
}

export interface RecommendCocktailItemDto {
  rank?: number;
  id?: number;
  code?: number[];
  score?: number[];
  cocktail?: CocktailListItemDto;
}

export interface RecommendCocktailPayloadDto {
  mode?: string | null;
  seedId?: number;
  seedCode?: number[];
  predCode?: number[];
  items?: RecommendCocktailItemDto[];
  status?: RecommendCocktailCodeStatusDto;
}

export interface RecommendCocktailCardModel {
  cocktailId: number;
  title: string;
  subtitle: string;
  description: string;
  badgeText: string;
  metaText: string;
  imageSource: ResourceStr | string;
}

function normalizeText(value?: string | null): string {
  return typeof value === 'string' ? value.trim() : '';
}

function resolveRecommendImage(item: CocktailListItemDto): string {
  const candidates: Array<string | null | undefined> = [
    item.imageUrlCard,
    item.imageUrlThumb,
    item.heroImage,
    item.imageUrl
  ];

  for (let index: number = 0; index < candidates.length; index += 1) {
    const candidate: string = normalizeText(candidates[index]);
    if (candidate.length > 0) {
      return buildPublicAssetUrl(candidate);
    }
  }

  return '';
}

function buildSubtitle(item: CocktailListItemDto): string {
  const segments: string[] = [];
  const englishName: string = normalizeText(item.englishName);
  const difficulty: string = normalizeText(item.difficulty);
  const abv: string = normalizeText(item.abv);

  if (englishName.length > 0) {
    segments.push(englishName);
  }
  if (difficulty.length > 0) {
    segments.push(difficulty);
  }
  if (abv.length > 0) {
    segments.push(abv);
  }

  return segments.join(' · ');
}

export function toRecommendCocktailCardModel(item: RecommendCocktailItemDto): RecommendCocktailCardModel | null {
  if (!item.cocktail || typeof item.cocktail.id !== 'number') {
    return null;
  }

  const title: string = normalizeText(item.cocktail.name);
  if (title.length === 0) {
    return null;
  }

  const description: string = normalizeText(item.cocktail.description);
  const category: string = normalizeText(item.cocktail.category);
  const subtitle: string = buildSubtitle(item.cocktail);
  const cardModel: RecommendCocktailCardModel = {
    cocktailId: item.cocktail.id,
    title: title,
    subtitle: subtitle,
    description: description.length > 0 ? description : '这杯酒的介绍正在补充中，可先进入详情页查看。',
    badgeText: category.length > 0 ? category : '推荐配方',
    metaText: '查看酒谱',
    imageSource: resolveRecommendImage(item.cocktail)
  } as RecommendCocktailCardModel;
  return cardModel;
}
