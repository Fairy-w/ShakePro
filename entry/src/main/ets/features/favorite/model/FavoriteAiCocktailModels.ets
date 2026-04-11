export interface SaveAiCocktailFavoriteRequest {
  recipeKey?: string;
  name: string;
  description?: string;
  materials: string[];
  steps: string[];
  prompt?: string;
  source?: string;
}

export interface FavoriteAiCocktailMutationResponse {
  favoriteId: number;
  favorited: boolean;
}

export interface FavoriteAiCocktailItem {
  favoriteId: number;
  recipeKey: string;
  name: string;
  description: string;
  materials: string[];
  steps: string[];
  prompt: string;
  source: string;
  createdAt: string;
}

export interface FavoriteAiCocktailListResponse {
  total: number;
  list: FavoriteAiCocktailItem[];
}

export interface FavoriteAiCocktailStatusResponse {
  favorited: boolean;
  favoriteId?: number | null;
}

export interface FavoriteAiCocktailListQuery {
  pageNo?: number;
  pageSize?: number;
  keyword?: string;
  sort?: string;
}
