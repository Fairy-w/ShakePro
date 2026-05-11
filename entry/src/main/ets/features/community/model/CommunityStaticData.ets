export interface CommunityStat {
  id: string;
  value: string;
  label: string;
  detail: string;
}

export interface CommunityTopic {
  id: string;
  title: string;
  subtitle: string;
  countText: string;
  accentColor: string;
  softColor: string;
}

export interface CommunityChallenge {
  id: string;
  title: string;
  subtitle: string;
  joinedText: string;
  rewardText: string;
  deadlineText: string;
  accentColor: string;
  softColor: string;
}

export interface CommunityCreator {
  id: string;
  name: string;
  role: string;
  avatar: ResourceStr;
  badge: string;
  heatText: string;
}

export interface CommunityPost {
  id: string;
  topicId: string;
  title: string;
  excerpt: string;
  authorName: string;
  authorRole: string;
  authorAvatar: ResourceStr;
  cover: ResourceStr;
  publishText: string;
  tag: string;
  likes: number;
  comments: number;
  saves: number;
  accentColor: string;
  softColor: string;
}

export interface CommunityPostDetail {
  postId: string;
  summary: string;
  bodyParagraphs: string[];
  tips: string[];
  moodTags: string[];
}

export interface CommunityComment {
  id: string;
  postId: string;
  authorName: string;
  authorRole: string;
  authorAvatar: ResourceStr;
  publishText: string;
  content: string;
  likes: number;
}

export const COMMUNITY_STATS: CommunityStat[] = [
  {
    id: 'member',
    value: '2.6k',
    label: '活跃酒友',
    detail: '近 7 天持续发帖与互动'
  },
  {
    id: 'post',
    value: '118',
    label: '今日动态',
    detail: '作品晒图、配方交流同步更新'
  },
  {
    id: 'challenge',
    value: '9',
    label: '进行中的挑战',
    detail: '适合拉新与社区共创的固定活动'
  }
];

export const COMMUNITY_TOPICS: CommunityTopic[] = [
  {
    id: 'all',
    title: '全部',
    subtitle: '浏览完整社区内容',
    countText: '48 条新帖',
    accentColor: '#72655D',
    softColor: '#EEE6DF'
  },
  {
    id: 'showcase',
    title: '作品晒图',
    subtitle: '发自己的成品与杯饰灵感',
    countText: '16 条新帖',
    accentColor: '#84695C',
    softColor: '#F2E5DC'
  },
  {
    id: 'flavor',
    title: '风味讨论',
    subtitle: '聊口感、层次和平衡',
    countText: '11 条新帖',
    accentColor: '#706158',
    softColor: '#EEE5DD'
  },
  {
    id: 'party',
    title: '聚会特调',
    subtitle: '多人场景与批量出杯经验',
    countText: '9 条新帖',
    accentColor: '#5E5853',
    softColor: '#ECE6E0'
  },
  {
    id: 'novice',
    title: '新手问答',
    subtitle: '从材料、工具到做法都能问',
    countText: '12 条新帖',
    accentColor: '#8B6B5E',
    softColor: '#F4E7DE'
  }
];

export const COMMUNITY_CHALLENGES: CommunityChallenge[] = [
  {
    id: 'weekend',
    title: '周末微醺挑战',
    subtitle: '用 3 种材料做出轻盈、适合聚会的高球配方。',
    joinedText: '264 人已参与',
    rewardText: '精选作品会进入首页轮播推荐',
    deadlineText: '截止至 04-26',
    accentColor: '#6A5B52',
    softColor: '#EFE5DD'
  },
  {
    id: 'garnish',
    title: '杯饰设计联动',
    subtitle: '围绕柑橘、薄荷与香料做出视觉更完整的作品。',
    joinedText: '139 人已参与',
    rewardText: '获赞 TOP 3 可获得社区徽章',
    deadlineText: '截止至 04-28',
    accentColor: '#876253',
    softColor: '#F2E5DD'
  }
];

export const COMMUNITY_CREATORS: CommunityCreator[] = [
  {
    id: 'lin',
    name: '阿林',
    role: '清爽风味主理人',
    avatar: $r('app.media.transitionanimation_avator1'),
    badge: 'TOP 1',
    heatText: '本周获赞 428'
  },
  {
    id: 'mo',
    name: 'Momo',
    role: '聚会出杯策划',
    avatar: $r('app.media.transitionanimation_avator3'),
    badge: 'TOP 2',
    heatText: '本周获赞 317'
  },
  {
    id: 'yue',
    name: '月岛',
    role: '新手答疑志愿者',
    avatar: $r('app.media.transitionanimation_avator5'),
    badge: 'TOP 3',
    heatText: '回复 86 条问题'
  },
  {
    id: 'rush',
    name: 'Rush',
    role: '杯饰与摆盘实验派',
    avatar: $r('app.media.myself'),
    badge: 'NEW',
    heatText: '连续 6 天打卡'
  }
];

export const COMMUNITY_POSTS: CommunityPost[] = [
  {
    id: 'post-02',
    topicId: 'flavor',
    title: '干马天尼如果想更柔一点，橄榄盐水到底要不要加？',
    excerpt: '我最近在试更容易入口的版本，想保留干净酒感，但又不希望第一口太尖。欢迎大家分享你们常用的比例和搅拌时长。',
    authorName: '月岛',
    authorRole: '新手答疑志愿者',
    authorAvatar: $r('app.media.transitionanimation_avator5'),
    cover: $r('app.media.dry_martini'),
    publishText: '38 分钟前',
    tag: '风味讨论',
    likes: 96,
    comments: 41,
    saves: 37,
    accentColor: '#726159',
    softColor: '#EEE6DE'
  },
  {
    id: 'post-03',
    topicId: 'party',
    title: '8 人聚会批量出杯，我这样拆成前置基底真的省很多事',
    excerpt: '提前把酸甜平衡和基酒比例都校准后，现场只补冰和气泡，出杯速度能稳住，口感也不会因为手忙脚乱而飘。',
    authorName: 'Momo',
    authorRole: '聚会出杯策划',
    authorAvatar: $r('app.media.transitionanimation_avator3'),
    cover: $r('app.media.cocktail_5'),
    publishText: '1 小时前',
    tag: '聚会特调',
    likes: 143,
    comments: 19,
    saves: 66,
    accentColor: '#5E5853',
    softColor: '#ECE6E0'
  },
  {
    id: 'post-04',
    topicId: 'novice',
    title: '刚入门只买 4 样材料，优先级应该怎么排？',
    excerpt: '目标是先能覆盖清爽和偏酸两类基础风味，不追求特别复杂，家里工具也只有雪克壶和量杯。',
    authorName: 'Rush',
    authorRole: '杯饰与摆盘实验派',
    authorAvatar: $r('app.media.myself'),
    cover: $r('app.media.cocktail_1'),
    publishText: '2 小时前',
    tag: '新手问答',
    likes: 88,
    comments: 32,
    saves: 45,
    accentColor: '#8A695E',
    softColor: '#F3E6DE'
  },
  {
    id: 'post-05',
    topicId: 'showcase',
    title: '用现有库存复刻了 Zombie，顺手把杯饰改成了更热带的版本',
    excerpt: '菠萝叶和橙皮卷叠起来之后，视觉冲击比原来强很多，拍照特别出片，适合社区作品展示。',
    authorName: 'Nico',
    authorRole: '视觉呈现爱好者',
    authorAvatar: $r('app.media.transitionanimation_avator6'),
    cover: $r('app.media.zombie'),
    publishText: '今天 09:20',
    tag: '作品晒图',
    likes: 131,
    comments: 24,
    saves: 58,
    accentColor: '#83685B',
    softColor: '#F1E5DB'
  }
];

export const COMMUNITY_POST_DETAILS: CommunityPostDetail[] = [
  {
    postId: 'post-02',
    summary: '这是一条围绕干马天尼口感微调展开的讨论帖，重点是如何在不破坏骨架的前提下，让入口更圆润。',
    bodyParagraphs: [
      '我最近反复在试两件事：一是苦艾酒比例稍微往上提一点点，二是在搅拌后加入极少量橄榄盐水。前者能让香气更完整，后者则会让酒体的轮廓变得更柔和，但如果加过头，很容易把原本干净的线条打散。',
      '目前我比较喜欢的做法是先把金酒和苦艾酒维持在偏经典的比例，再通过搅拌时长去控制稀释度。比起直接增加辅料，稀释往往更能决定第一口是不是“刺”。',
      '如果你是给新手做第一杯干马天尼，我反而建议先从更冷、更充分搅拌的版本开始，再决定是否加入盐水。这样能更清楚地分辨到底是温度问题、稀释问题，还是配方本身的问题。'
    ],
    tips: [
      '先调搅拌时长，再调盐水比例。',
      '橄榄盐水建议从几滴开始试，不要一次加太多。',
      '酒液更冷时，入口刺激感通常会明显下降。'
    ],
    moodTags: ['经典短饮', '搅拌技巧', '口感平衡']
  },
  {
    postId: 'post-03',
    summary: '这是一个偏实战型的聚会出杯经验帖，核心是把现场操作拆成前置准备与现场收尾两段，提高稳定性。',
    bodyParagraphs: [
      '我会先在量杯里把基酒、酸、甜都做成一个大基底，提前校准风味。这样真正聚会开始时，只需要补冰、气泡和装饰，出杯压力会小很多。',
      '如果人数在 6 到 10 人之间，建议至少预留两种杯型：一个偏正式、一个偏轻松。因为同一套基底换不同杯型和装饰，呈现会立刻不一样。',
      '真正节省时间的不是“省步骤”，而是把容易出错的步骤放到前面。只要把比例先稳住，现场就可以把更多注意力放在节奏和交流上。'
    ],
    tips: [
      '聚会前先做一轮试喝，确认稀释后的最终风味。',
      '大基底最好单独冷藏，现场只补冰和气泡。',
      '提前准备好装饰物和杯具，能明显减少慌乱。'
    ],
    moodTags: ['聚会流程', '批量出杯', '效率优化']
  },
  {
    postId: 'post-04',
    summary: '这是一条典型的新手求助帖，目标是在有限预算里优先搭建一个能覆盖清爽与偏酸风味的基础组合。',
    bodyParagraphs: [
      '如果只能先买 4 样材料，我会优先考虑一支基酒、一支橙味利口酒、一种酸味来源和一种气泡延展材料。这样虽然选择不多，但能很快搭出几条经典线路。',
      '对新手来说，最重要的不是材料数量，而是能不能快速理解“基酒、酸、甜、稀释”之间的关系。只要这四个角色感知清楚，后面扩展会非常快。',
      '工具也不需要一开始就上满。雪克壶、量杯、滤冰器加一个长吧勺，已经足够覆盖大部分入门配方。'
    ],
    tips: [
      '优先买通用度更高的基酒和利口酒。',
      '先把 2 到 3 个经典模板喝懂，再继续扩库存。',
      '记录每次调整的比例，比一次买很多材料更有价值。'
    ],
    moodTags: ['新手入门', '基础库存', '低成本搭建']
  },
  {
    postId: 'post-05',
    summary: '这条帖子更偏向作品展示，重点在于如何通过杯饰和构图，让经典配方在视觉上更有热带气质。',
    bodyParagraphs: [
      '这次我没有去大改 Zombie 的骨架，而是把主要精力放在视觉呈现上。菠萝叶的高度、橙皮卷的方向，以及杯口留白的比例，都会直接影响照片质感。',
      '我发现作品在社区里被收藏，很多时候不是因为配方更复杂，而是因为观众能一眼看出这杯酒的气氛和场景。',
      '如果你也想提升作品展示感，建议先固定一个自己的构图模板。哪怕只是统一角度、背景和光线，内容质感都会稳定很多。'
    ],
    tips: [
      '优先控制背景和光线，再考虑更复杂的杯饰。',
      '杯饰高度最好和杯体比例有呼应，不要只追求堆叠。',
      '拍照前擦干杯壁水痕，成片会更干净。'
    ],
    moodTags: ['作品展示', '杯饰设计', '拍摄表达']
  }
];

export const COMMUNITY_COMMENTS: CommunityComment[] = [
  {
    id: 'comment-01',
    postId: 'post-02',
    authorName: '阿林',
    authorRole: '清爽风味主理人',
    authorAvatar: $r('app.media.transitionanimation_avator1'),
    publishText: '18 分钟前',
    content: '我一般会先把搅拌时间拉长，再决定要不要上盐水。很多时候真正让口感变尖的是温度和稀释不到位。',
    likes: 21
  },
  {
    id: 'comment-02',
    postId: 'post-03',
    authorName: 'Rush',
    authorRole: '杯饰与摆盘实验派',
    authorAvatar: $r('app.media.myself'),
    publishText: '42 分钟前',
    content: '这个思路很适合活动场景，我之前也是把装饰全部前置准备，现场压力会小很多。',
    likes: 17
  },
  {
    id: 'comment-03',
    postId: 'post-04',
    authorName: 'Momo',
    authorRole: '聚会出杯策划',
    authorAvatar: $r('app.media.transitionanimation_avator3'),
    publishText: '1 小时前',
    content: '如果是家用场景，我会建议先把高频模板跑熟，再慢慢补材料，不然很容易买一堆但用不起来。',
    likes: 13
  },
  {
    id: 'comment-04',
    postId: 'post-05',
    authorName: '月岛',
    authorRole: '新手答疑志愿者',
    authorAvatar: $r('app.media.transitionanimation_avator5'),
    publishText: '今天 10:15',
    content: '这张图真的很出片，特别是菠萝叶和橙皮卷的层次感，感觉很适合做社区封面。',
    likes: 24
  }
];

export function findCommunityPostById(postId: string): CommunityPost | null {
  for (let index: number = 0; index < COMMUNITY_POSTS.length; index += 1) {
    if (COMMUNITY_POSTS[index].id === postId) {
      return COMMUNITY_POSTS[index];
    }
  }
  return null;
}

export function findCommunityPostDetailById(postId: string): CommunityPostDetail | null {
  for (let index: number = 0; index < COMMUNITY_POST_DETAILS.length; index += 1) {
    if (COMMUNITY_POST_DETAILS[index].postId === postId) {
      return COMMUNITY_POST_DETAILS[index];
    }
  }
  return null;
}

export function getCommunityCommentsByPostId(postId: string): CommunityComment[] {
  const result: CommunityComment[] = [];
  for (let index: number = 0; index < COMMUNITY_COMMENTS.length; index += 1) {
    if (COMMUNITY_COMMENTS[index].postId === postId) {
      result.push(COMMUNITY_COMMENTS[index]);
    }
  }
  return result;
}
