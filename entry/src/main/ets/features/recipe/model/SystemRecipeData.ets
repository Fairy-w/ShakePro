import { buildPublicAssetUrl } from '../../../common/constants/ApiConfig';

export interface FlavorMetric {
  label: string;
  value: number;
}

export interface RecipeIngredient {
  name: string;
  amount: string;
  note: string;
}

export interface RecipeStep {
  title: string;
  detail: string;
}

export type RecipeImageSource = string | Resource;

export interface SystemRecipe {
  id: string;
  name: string;
  englishName: string;
  category: string;
  subtitle: string;
  heroImage: RecipeImageSource;
  heroDetailImage: RecipeImageSource;
  highlight: string;
  description: string;
  story: string;
  difficulty: string;
  abv: string;
  glass: string;
  garnish: string;
  flavorTags: string[];
  flavorMetrics: FlavorMetric[];
  pairings: string[];
  serviceNotes: string[];
  ingredients: RecipeIngredient[];
  steps: RecipeStep[];
}

export const EMPTY_SYSTEM_RECIPE: SystemRecipe = {
  id: '',
  name: '',
  englishName: '',
  category: '',
  subtitle: '',
  heroImage: '',
  heroDetailImage: '',
  highlight: '',
  description: '',
  story: '',
  difficulty: '',
  abv: '',
  glass: '',
  garnish: '',
  flavorTags: [],
  flavorMetrics: [],
  pairings: [],
  serviceNotes: [],
  ingredients: [],
  steps: []
};

export function resolveRecipeHeroImage(heroImage: RecipeImageSource): RecipeImageSource {
  if (typeof heroImage !== 'string' || heroImage.length === 0) {
    return heroImage;
  }

  return buildPublicAssetUrl(heroImage);
}

export function getFlavorMetricList(flavorMetrics: FlavorMetric[]): FlavorMetric[] {
  return flavorMetrics;
}
