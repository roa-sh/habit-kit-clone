import { format, isToday, isThisWeek, isThisMonth, parseISO } from "date-fns";

export const formatDate = (date, formatString = "yyyy-MM-dd") => {
  const dateObj = typeof date === "string" ? parseISO(date) : date;
  return format(dateObj, formatString);
};

export const isTodayDate = (date) => {
  const dateObj = typeof date === "string" ? parseISO(date) : date;
  return isToday(dateObj);
};

export const isInCurrentWeek = (date) => {
  const dateObj = typeof date === "string" ? parseISO(date) : date;
  return isThisWeek(dateObj, { weekStartsOn: 1 });
};

export const isInCurrentMonth = (date) => {
  const dateObj = typeof date === "string" ? parseISO(date) : date;
  return isThisMonth(dateObj);
};

export const getDayOfWeek = (date) => {
  const dateObj = typeof date === "string" ? parseISO(date) : date;
  return format(dateObj, "EEE");
};

export const getShortMonth = (date) => {
  const dateObj = typeof date === "string" ? parseISO(date) : date;
  return format(dateObj, "MMM");
};

export const getTodayString = () => {
  return format(new Date(), "yyyy-MM-dd");
};

