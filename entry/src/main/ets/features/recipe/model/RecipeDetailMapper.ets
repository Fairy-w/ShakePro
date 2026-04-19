
import {
  RecipeIngredient,
  RecipeStep,
  SystemRecipe,
  FlavorMetric
} from './SystemRecipeData';
import {
  CocktailDetailDto,
  CocktailFlavorMetricDto,
  CocktailMaterialDto,
  CocktailStepDto,
  resolveCocktailDetailHeroImage,
  resolveCocktailDetailPreviewImage
} from '../../cocktail/model/CocktailDetailModels';

function toSafeString(value?: string | null): string {
  return value ?? '';
}

function buildRecipeIngredients(materials?: CocktailMaterialDto[]): RecipeIngredient[] {
  if (!materials || materials.length === 0) {
    return [];
  }

  return [...materials]
    .sort((left: CocktailMaterialDto, right: CocktailMaterialDto): number => {
      return (left.sortOrder ?? 0) - (right.sortOrder ?? 0);
    })
    .map((item: CocktailMaterialDto): RecipeIngredient => {
      return {
        name: toSafeString(item.name) || toSafeString(item.displayName),
        amount: toSafeString(item.amount),
        note: toSafeString(item.note)
      } as RecipeIngredient;
    });
}

function buildStructuredSteps(steps?: CocktailStepDto[]): RecipeStep[] {
  if (!steps || steps.length === 0) {
    return [];
  }

  return [...steps]
    .sort((left: CocktailStepDto, right: CocktailStepDto): number => {
      return (left.order ?? 0) - (right.order ?? 0);
    })
    .map((item: CocktailStepDto, index: number): RecipeStep => {
      const fallbackTitle = `步骤 ${index + 1}`;
      return {
        title: toSafeString(item.title) || fallbackTitle,
        detail: toSafeString(item.detail)
      } as RecipeStep;
    });
}

function buildLegacySteps(legacySteps?: string | null): RecipeStep[] {
  const text = toSafeString(legacySteps).trim();
  if (text.length === 0) {
    return [];
  }

  return text
    .split('\n')
    .map((line: string): string => line.trim())
    .filter((line: string): boolean => line.length > 0)
    .map((line: string, index: number): RecipeStep => {
      return {
        title: `步骤 ${index + 1}`,
        detail: line.replace(/^\d+\.\s*/, '')
      } as RecipeStep;
    });
}

function buildRecipeSteps(dto: CocktailDetailDto): RecipeStep[] {
  const structuredSteps = buildStructuredSteps(dto.steps);
  if (structuredSteps.length > 0) {
    return structuredSteps;
  }
  return buildLegacySteps(dto.legacySteps);
}
function buildFlavorMetrics(flavorMetrics?: CocktailFlavorMetricDto[]): FlavorMetric[] {
  if (!flavorMetrics || flavorMetrics.length === 0) {
    return [];
  }

  return [...flavorMetrics]
    .sort((left: CocktailFlavorMetricDto, right: CocktailFlavorMetricDto): number => {
      return (left.sortOrder ?? 0) - (right.sortOrder ?? 0);
    })
    .map((item: CocktailFlavorMetricDto): FlavorMetric => {
      return {
        label: toSafeString(item.name),
        value: item.value ?? 0
      };
    })
    .filter((item: FlavorMetric): boolean => item.label.length > 0);
}

export function mapCocktailDetailToSystemRecipe(dto: CocktailDetailDto): SystemRecipe {
  return {
    id: String(dto.id),
    name: dto.name,
    englishName: toSafeString(dto.englishName),
    category: toSafeString(dto.category),
    subtitle: toSafeString(dto.subtitle),
    heroImage: resolveCocktailDetailHeroImage(dto),
    heroDetailImage: resolveCocktailDetailPreviewImage(dto),
    highlight: toSafeString(dto.highlight),
    description: toSafeString(dto.description),
    story: toSafeString(dto.story),
    difficulty: toSafeString(dto.difficulty),
    abv: toSafeString(dto.abv),
    glass: toSafeString(dto.glass),
    garnish: toSafeString(dto.garnish),
    flavorTags: dto.flavorTags ?? [],
    flavorMetrics: buildFlavorMetrics(dto.flavorMetrics),
    pairings: dto.pairings ?? [],
    serviceNotes: dto.serviceNotes ?? [],
    ingredients: buildRecipeIngredients(dto.materials),
    steps: buildRecipeSteps(dto)
  } as SystemRecipe;
}
