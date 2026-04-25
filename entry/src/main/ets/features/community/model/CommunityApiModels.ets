import { buildPublicAssetUrl } from '../../../common/constants/ApiConfig';

export interface CommunityAuthorDto {
  userId?: string;
  nickname?: string;
  avatar?: string;
}

export interface CommunityPostListItemDto {
  postId?: string;
  title?: string;
  summary?: string;
  content?: string;
  coverImage?: string;
  author?: CommunityAuthorDto;
  tags?: string[];
  likeCount?: number;
  commentCount?: number;
  favoriteCount?: number;
  publishTime?: string;
}

export interface CommunityPostPageDto {
  list?: CommunityPostListItemDto[];
  pageNo?: number;
  pageSize?: number;
  total?: number;
  hasMore?: boolean;
}

export interface CommunityPostDetailDto {
  postId?: string;
  title?: string;
  summary?: string;
  content?: string;
  images?: string[];
  author?: CommunityAuthorDto;
  tags?: string[];
  likeCount?: number;
  commentCount?: number;
  favoriteCount?: number;
  publishTime?: string;
}

export interface CommunityPostListQuery {
  pageNo?: number;
  pageSize?: number;
}

export interface CreateCommunityPostRequest {
  title?: string;
  content: string;
  images?: string[];
  tags?: string[];
}

export interface CreateCommunityPostResponse {
  postId?: string;
}

export interface UploadCommunityImageResponse {
  url?: string;
}

export interface CommunityPostCardModel {
  id: string;
  title: string;
  summary: string;
  coverImage: string;
  authorName: string;
  authorAvatar: string;
  publishText: string;
  primaryTag: string;
  tags: string[];
  likeCount: number;
  commentCount: number;
  favoriteCount: number;
  imageHeight: number;
  excerptLineCount: number;
}

export interface CommunityPostDetailModel {
  id: string;
  title: string;
  summary: string;
  content: string;
  bodyParagraphs: string[];
  images: string[];
  authorName: string;
  authorAvatar: string;
  publishText: string;
  primaryTag: string;
  tags: string[];
  likeCount: number;
  commentCount: number;
  favoriteCount: number;
}

export function createEmptyCommunityPostDetailModel(): CommunityPostDetailModel {
  return {
    id: '',
    title: '社区笔记',
    summary: '',
    content: '',
    bodyParagraphs: [],
    images: [],
    authorName: '社区酒友',
    authorAvatar: '',
    publishText: '',
    primaryTag: '社区笔记',
    tags: [],
    likeCount: 0,
    commentCount: 0,
    favoriteCount: 0
  } as CommunityPostDetailModel;
}

export function toCommunityPostCardModel(dto: CommunityPostListItemDto, index: number): CommunityPostCardModel {
  const titleText = resolvePostTitle(dto.title, dto.summary, dto.content);
  const summaryText = resolveSummary(dto.summary, dto.content);
  const tagList = normalizeStringArray(dto.tags);
  const author = dto.author ?? {};
  return {
    id: normalizeText(dto.postId, 'post-' + (index + 1).toString()),
    title: titleText,
    summary: summaryText,
    coverImage: normalizeImageUrl(dto.coverImage),
    authorName: normalizeText(author.nickname, '社区酒友'),
    authorAvatar: normalizeImageUrl(author.avatar),
    publishText: formatCommunityPublishTime(dto.publishTime),
    primaryTag: tagList.length > 0 ? tagList[0] : '社区笔记',
    tags: tagList,
    likeCount: normalizeCount(dto.likeCount),
    commentCount: normalizeCount(dto.commentCount),
    favoriteCount: normalizeCount(dto.favoriteCount),
    imageHeight: index % 3 === 0 ? 224 : 188,
    excerptLineCount: index % 2 === 0 ? 3 : 2
  } as CommunityPostCardModel;
}

export function toCommunityPostDetailModel(dto: CommunityPostDetailDto): CommunityPostDetailModel {
  const titleText = resolvePostTitle(dto.title, dto.summary, dto.content);
  const summaryText = resolveSummary(dto.summary, dto.content);
  const bodyText = normalizeText(dto.content, summaryText);
  const bodyParagraphs = splitBodyParagraphs(bodyText);
  const tagList = normalizeStringArray(dto.tags);
  const author = dto.author ?? {};
  return {
    id: normalizeText(dto.postId),
    title: titleText,
    summary: summaryText,
    content: bodyText,
    bodyParagraphs: bodyParagraphs,
    images: normalizeImageArray(dto.images),
    authorName: normalizeText(author.nickname, '社区酒友'),
    authorAvatar: normalizeImageUrl(author.avatar),
    publishText: formatCommunityPublishTime(dto.publishTime),
    primaryTag: tagList.length > 0 ? tagList[0] : '社区笔记',
    tags: tagList,
    likeCount: normalizeCount(dto.likeCount),
    commentCount: normalizeCount(dto.commentCount),
    favoriteCount: normalizeCount(dto.favoriteCount)
  } as CommunityPostDetailModel;
}

function normalizeText(value?: string | null, fallback: string = ''): string {
  if (typeof value !== 'string') {
    return fallback;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : fallback;
}

function normalizeCount(value?: number | null): number {
  return typeof value === 'number' && value > 0 ? value : 0;
}

function normalizeImageUrl(value?: string | null): string {
  const normalized = normalizeText(value);
  if (normalized.length === 0) {
    return '';
  }
  return buildPublicAssetUrl(normalized);
}

function normalizeImageArray(items?: string[] | null): string[] {
  if (!Array.isArray(items)) {
    return [];
  }
  const result: string[] = [];
  for (let index: number = 0; index < items.length; index += 1) {
    const imageUrl = normalizeImageUrl(items[index]);
    if (imageUrl.length > 0) {
      result.push(imageUrl);
    }
  }
  return result;
}

function normalizeStringArray(items?: string[] | null): string[] {
  if (!Array.isArray(items)) {
    return [];
  }
  const result: string[] = [];
  for (let index: number = 0; index < items.length; index += 1) {
    const value = normalizeText(items[index]);
    if (value.length > 0) {
      result.push(value);
    }
  }
  return result;
}

function resolvePostTitle(title?: string | null, summary?: string | null, content?: string | null): string {
  const normalizedTitle = normalizeText(title);
  if (normalizedTitle.length > 0) {
    return normalizedTitle;
  }

  const summaryTitle = buildPreviewTitle(normalizeText(summary));
  if (summaryTitle.length > 0) {
    return summaryTitle;
  }

  const contentTitle = buildPreviewTitle(normalizeText(content));
  if (contentTitle.length > 0) {
    return contentTitle;
  }

  return '社区笔记';
}

function resolveSummary(summary?: string | null, content?: string | null): string {
  const normalizedSummary = normalizeText(summary);
  if (normalizedSummary.length > 0) {
    return normalizedSummary;
  }
  const contentPreview = buildPreviewSummary(normalizeText(content));
  if (contentPreview.length > 0) {
    return contentPreview;
  }
  return '这篇笔记还没有摘要，先从正文里看看作者的配方思路。';
}

function buildPreviewTitle(value: string): string {
  if (value.length === 0) {
    return '';
  }
  return value.length > 20 ? value.slice(0, 20) + '...' : value;
}

function buildPreviewSummary(value: string): string {
  if (value.length === 0) {
    return '';
  }
  return value.length > 54 ? value.slice(0, 54) + '...' : value;
}

function splitBodyParagraphs(content: string): string[] {
  const result: string[] = [];
  if (content.length === 0) {
    return result;
  }

  const lines = content.split('\n');
  for (let index: number = 0; index < lines.length; index += 1) {
    const item = lines[index].trim();
    if (item.length > 0) {
      result.push(item);
    }
  }

  if (result.length > 0) {
    return result;
  }

  result.push(content);
  return result;
}

export function formatCommunityPublishTime(value?: string | null): string {
  const normalized = normalizeText(value);
  if (normalized.length === 0) {
    return '刚刚';
  }

  const parsedDate = new Date(normalized);
  if (Number.isNaN(parsedDate.getTime())) {
    return normalized;
  }

  const diffMs = Date.now() - parsedDate.getTime();
  if (diffMs <= 0) {
    return '刚刚';
  }

  const minuteMs = 60 * 1000;
  const hourMs = 60 * minuteMs;
  const dayMs = 24 * hourMs;

  if (diffMs < minuteMs) {
    return '刚刚';
  }
  if (diffMs < hourMs) {
    return Math.floor(diffMs / minuteMs).toString() + ' 分钟前';
  }
  if (diffMs < dayMs) {
    return Math.floor(diffMs / hourMs).toString() + ' 小时前';
  }
  if (diffMs < 7 * dayMs) {
    return Math.floor(diffMs / dayMs).toString() + ' 天前';
  }

  const year = parsedDate.getFullYear().toString();
  const month = (parsedDate.getMonth() + 1).toString().padStart(2, '0');
  const day = parsedDate.getDate().toString().padStart(2, '0');
  return year + '-' + month + '-' + day;
}
