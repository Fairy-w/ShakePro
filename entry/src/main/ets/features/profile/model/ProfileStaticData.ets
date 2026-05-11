import { RoutePaths } from '../../../core/router/RoutePaths';
import { UiTokens } from '../../../common/constants/UiTokens';

export interface ProfileOverviewData {
  avatar: ResourceStr;
  displayName: string;
  accountId: string;
  headline: string;
  cityText: string;
  joinText: string;
}

export interface ProfileMenuItem {
  id: string;
  title: string;
  subtitle: string;
  icon: ResourceStr;
  route: string;
  actionKind: string;
  actionMessage: string;
  trailingText: string;
  accentColor: string;
  softColor: string;
}

export interface ProfilePostPreviewItem {
  id: string;
  title: string;
  summary: string;
  publishText: string;
  statusText: string;
}

export const PROFILE_OVERVIEW: ProfileOverviewData = {
  avatar: $r('app.media.myself'),
  displayName: '林初',
  accountId: '@linchu_shake',
  headline: '偏爱清爽、低酒精和果香结构，最近在整理自己的家用小酒柜。',
  cityText: '成都',
  joinText: '加入 ShakePro 第 128 天'
} as ProfileOverviewData;

export const PROFILE_SHORTCUTS: ProfileMenuItem[] = [
  {
    id: 'favorite-page',
    title: '我的收藏',
    subtitle: '集中查看系统酒谱收藏与 AI 收藏结果。',
    icon: $r('app.media.favorite_recipes'),
    route: RoutePaths.FAVORITE,
    actionKind: 'route',
    actionMessage: '',
    trailingText: '',
    accentColor: UiTokens.accentWarm,
    softColor: UiTokens.surfaceWarm
  } as ProfileMenuItem,
  {
    id: 'my-posts',
    title: '我的帖子',
    subtitle: '查看自己已经发布过的社区笔记。',
    icon: $r('app.media.friend'),
    route: RoutePaths.PROFILE_POSTS,
    actionKind: 'route',
    actionMessage: '',
    trailingText: '',
    accentColor: UiTokens.textAccent,
    softColor: UiTokens.primarySoft
  } as ProfileMenuItem,
  {
    id: 'settings',
    title: '设置',
    subtitle: '账号、通知和退出登录都放在这里。',
    icon: $r('app.media.menu'),
    route: RoutePaths.PROFILE_SETTINGS,
    actionKind: 'route',
    actionMessage: '',
    trailingText: '',
    accentColor: UiTokens.textPrimary,
    softColor: UiTokens.surfaceMuted
  } as ProfileMenuItem
];

export const PROFILE_SETTING_ITEMS: ProfileMenuItem[] = [
  {
    id: 'account',
    title: '账号与安全',
    subtitle: '修改登录方式、绑定信息和账号状态。',
    icon: $r('app.media.account'),
    route: '',
    actionKind: 'toast',
    actionMessage: '账号与安全功能即将上线',
    trailingText: '',
    accentColor: UiTokens.textPrimary,
    softColor: UiTokens.surfaceMuted
  } as ProfileMenuItem,
  {
    id: 'notification',
    title: '通知设置',
    subtitle: '管理互动提醒、系统消息和内容更新通知。',
    icon: $r('app.media.select'),
    route: '',
    actionKind: 'toast',
    actionMessage: '通知设置功能即将上线',
    trailingText: '',
    accentColor: UiTokens.aiPrimary,
    softColor: UiTokens.aiSoft
  } as ProfileMenuItem,
  {
    id: 'help',
    title: '帮助与反馈',
    subtitle: '遇到问题或有建议时可以从这里进入。',
    icon: $r('app.media.material_selection'),
    route: '',
    actionKind: 'toast',
    actionMessage: '帮助与反馈功能即将上线',
    trailingText: '',
    accentColor: UiTokens.warning,
    softColor: UiTokens.warningSoft
  } as ProfileMenuItem
];

export const PROFILE_POST_PREVIEWS: ProfilePostPreviewItem[] = [
  {
    id: 'post-1',
    title: '今晚这杯低酒精 Highball 记录一下',
    summary: '把柚子皮和苏打的比例重新调了一版，入口会更轻一点。',
    publishText: '昨天 21:16',
    statusText: '已发布'
  } as ProfilePostPreviewItem,
  {
    id: 'post-2',
    title: '试了下更适合晚餐后的清爽配方',
    summary: '把甜度再往下压一点，整体干净很多，适合夏天。',
    publishText: '04-18 19:42',
    statusText: '已发布'
  } as ProfilePostPreviewItem,
  {
    id: 'post-3',
    title: '家里现有材料也能配出的果香版本',
    summary: '没有复杂材料也能做，保留了果香和一点点草本层次。',
    publishText: '04-13 20:08',
    statusText: '已发布'
  } as ProfilePostPreviewItem
];
