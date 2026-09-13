// model/DataModel.ets
export interface LostItem {
  id: string;
  type: string;
  title: string;
  category: string;
  location: string;
  time: string;
  description: string;
  contact: string;
  status: string;
  isUrgent: boolean;
  isCollected: boolean;
  createdAt: string;
  viewCount: number;
}

export interface UserInfo {
  userName: string;
  userId: string;
  userType: 'student' | 'teacher';
}

export const DEFAULT_USER_INFO: UserInfo = {
  userName: '我的账号',
  userId: '202301XXXX',
  userType: 'student'
};

function generateId(): string {
  return Date.now().toString() + '_' + Math.random().toString(36).substring(2, 6);
}

export const INITIAL_ITEMS: LostItem[] = [
  {
    id: generateId(),
    type: 'lost',
    title: '黑色AirPods Pro',
    category: '数码',
    location: '图书馆3楼自习区',
    time: '2026-06-15 14:30',
    description: '黑色充电盒，右耳刻有名字"Zhang"，左耳略有划痕',
    contact: '13800138001',
    status: 'active',
    isUrgent: false,
    isCollected: false,
    createdAt: '2026-06-15 15:00',
    viewCount: 23,
  },
  {
    id: generateId(),
    type: 'found',
    title: '红色校园卡',
    category: '证件',
    location: '第二食堂门口',
    time: '2026-06-16 12:10',
    description: '红色卡面，卡号2024010123，姓名刘同学，背面贴有卡通贴纸',
    contact: '13800138002',
    status: 'active',
    isUrgent: true,
    isCollected: false,
    createdAt: '2026-06-16 12:30',
    viewCount: 45,
  },
  {
    id: generateId(),
    type: 'lost',
    title: '高等数学上册课本',
    category: '书籍',
    location: '教学楼A座303教室',
    time: '2026-06-16 10:00',
    description: '同济大学第七版，封面写有名字"王明"，内有大量笔记',
    contact: '13800138003',
    status: 'resolved',
    isUrgent: false,
    isCollected: false,
    createdAt: '2026-06-16 10:30',
    viewCount: 12,
  },
  {
    id: generateId(),
    type: 'found',
    title: '银色钥匙串',
    category: '生活用品',
    location: '操场看台',
    time: '2026-06-17 08:20',
    description: '银色钥匙串，挂有一个小熊挂件和3把钥匙，钥匙环有磨损',
    contact: '13800138004',
    status: 'active',
    isUrgent: false,
    isCollected: false,
    createdAt: '2026-06-17 09:00',
    viewCount: 8,
  },
  {
    id: generateId(),
    type: 'lost',
    title: '白色校服外套',
    category: '衣物',
    location: '体育馆更衣室',
    time: '2026-06-17 16:00',
    description: '白色运动外套，左胸印有校徽，尺码L，内袋有宿舍门禁卡',
    contact: '13800138005',
    status: 'active',
    isUrgent: false,
    isCollected: false,
    createdAt: '2026-06-17 16:30',
    viewCount: 6,
  },
  {
    id: generateId(),
    type: 'found',
    title: '华为MateBook充电器',
    category: '数码',
    location: '教学楼B座205教室',
    time: '2026-06-18 09:00',
    description: '白色65W充电器+Type-C线，线材有轻微磨损',
    contact: '13800138006',
    status: 'active',
    isUrgent: false,
    isCollected: false,
    createdAt: '2026-06-18 09:30',
    viewCount: 3,
  },
];

export function filterByCategory(items: LostItem[], category: string): LostItem[] {
  if (category === '全部') {
    return items;
  }
  return items.filter((item: LostItem) => item.category === category);
}

export function searchByKeyword(items: LostItem[], keyword: string): LostItem[] {
  if (!keyword.trim()) {
    return items;
  }
  const lowerKeyword: string = keyword.toLowerCase();
  return items.filter((item: LostItem) =>
  item.title.toLowerCase().includes(lowerKeyword) ||
  item.description.toLowerCase().includes(lowerKeyword) ||
  item.location.toLowerCase().includes(lowerKeyword)
  );
}

export function findItemById(items: LostItem[], id: string): LostItem | undefined {
  return items.find((item: LostItem) => item.id === id);
}