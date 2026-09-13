import { COLORS } from './Constant';

export function cardStyle() {
  return {
    backgroundColor: COLORS.cardBg,
    borderRadius: 12,
    padding: 16,
    margin: { left: 16, right: 16, top: 8, bottom: 8 },
  };
}

export function pageTitleStyle() {
  return {
    fontSize: 20,
    fontWeight: FontWeight.Bold,
    fontColor: COLORS.textPrimary,
  };
}

export function primaryButtonStyle() {
  return {
    backgroundColor: COLORS.primary,
    borderRadius: 8,
    padding: { left: 24, right: 24, top: 12, bottom: 12 },
  };
}