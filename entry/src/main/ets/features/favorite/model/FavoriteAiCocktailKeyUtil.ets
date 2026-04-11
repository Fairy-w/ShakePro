import { AiGenerateRecipeResponse } from '../../ai/model/AiGenerateRecipeResponse';

function normalizeText(value?: string): string {
  if (!value) {
    return '';
  }
  return value.trim().replace(/\s+/g, ' ');
}

function normalizeList(values: string[]): string[] {
  return values.map((value: string): string => normalizeText(value)).filter((value: string): boolean => value.length > 0);
}

function hashText(value: string): string {
  let hash: number = 2166136261;
  for (let index: number = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return (hash >>> 0).toString(16);
}

export function buildAiCocktailRecipeKey(recipe: AiGenerateRecipeResponse): string {
  const normalizedPayload: string = JSON.stringify({
    name: normalizeText(recipe.name),
    description: normalizeText(recipe.description),
    materials: normalizeList(recipe.materials),
    steps: normalizeList(recipe.steps)
  });

  return `ai_${hashText(normalizedPayload)}_${normalizedPayload.length}`;
}
