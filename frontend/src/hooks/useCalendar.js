import { useState, useCallback } from 'react'
import { startOfMonth, endOfMonth, eachDayOfInterval, format } from 'date-fns'

export const useCalendar = (initialDate = new Date()) => {
  const [currentDate, setCurrentDate] = useState(initialDate)
  
  const monthStart = startOfMonth(currentDate)
  const monthEnd = endOfMonth(currentDate)
  const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd })
  
  const monthName = format(currentDate, 'MMMM yyyy')
  const year = currentDate.getFullYear()
  const month = currentDate.getMonth() + 1
  
  const goToNextMonth = useCallback(() => {
    setCurrentDate(prev => {
      const newDate = new Date(prev)
      newDate.setMonth(newDate.getMonth() + 1)
      return newDate
    })
  }, [])
  
  const goToPreviousMonth = useCallback(() => {
    setCurrentDate(prev => {
      const newDate = new Date(prev)
      newDate.setMonth(newDate.getMonth() - 1)
      return newDate
    })
  }, [])
  
  const goToToday = useCallback(() => {
    setCurrentDate(new Date())
  }, [])
  
  return {
    currentDate,
    monthStart,
    monthEnd,
    daysInMonth,
    monthName,
    year,
    month,
    goToNextMonth,
    goToPreviousMonth,
    goToToday
  }
}

