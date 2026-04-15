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
