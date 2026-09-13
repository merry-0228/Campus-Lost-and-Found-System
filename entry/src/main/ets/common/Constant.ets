// common/Constants.ets
export const CATEGORIES: string[] = ['全部', '数码', '书籍', '生活用品', '证件', '衣物', '其他'];

export interface ColorScheme {
  primary: string;
  primaryLight: string;
  primaryGradient: string[];
  success: string;
  danger: string;
  warning: string;
  textPrimary: string;
  textSecondary: string;
  background: string;
  cardBg: string;
  divider: string;
  shadow: string;
}

export const COLORS: ColorScheme = {
  primary: '#5B7FFF',
  primaryLight: '#EEF1FF',
  primaryGradient: ['#5B7FFF', '#8B5CF6'],
  success: '#34C759',
  danger: '#FF3B30',
  warning: '#FF9500',
  textPrimary: '#1C1C1E',
  textSecondary: '#8E8E93',
  background: '#F8F9FC',
  cardBg: '#FFFFFF',
  divider: '#E5E5EA',
  shadow: 'rgba(91,127,255,0.15)',
};

export const CATEGORY_ICONS: Record<string, string> = {
  '数码': '📱',
  '书籍': '📚',
  '生活用品': '🔑',
  '证件': '🪪',
  '衣物': '👔',
  '其他': '📦',
};

export interface PublishType {
  label: string;
  value: string;
}

export const PUBLISH_TYPES: PublishType[] = [
  { label: '📢 失物招领', value: 'lost' },
  { label: '🔍 寻物启事', value: 'found' },
];