import React from 'react'
import { motion } from 'framer-motion'
import { format, parseISO, getDay } from 'date-fns'

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

const CalendarGrid = ({ days, color, onDayClick }) => {
  // getDay() returns 0 for Sunday, 1 for Monday, etc.
  // No need to adjust since we want Sunday (0) to be the first column
  const firstDayOffset = days.length > 0 
    ? getDay(parseISO(days[0].date))
    : 0
  
  return (
    <div>
      {/* Weekday Headers */}
      <div className="grid grid-cols-7 gap-2 mb-3">
        {WEEKDAYS.map(day => (
          <div key={day} className="text-center">
            <span className="text-[11px] font-bold text-ios-text-muted uppercase tracking-wide">
              {day}
            </span>
          </div>
        ))}
      </div>
      
      {/* Calendar Days */}
      <div className="grid grid-cols-7 gap-2">
        {/* Empty cells for offset */}
        {Array.from({ length: firstDayOffset }).map((_, i) => (
          <div key={`empty-${i}`} />
        ))}
        
        {/* Actual day cells */}
        {days.map((day, index) => (
          <CalendarDay
            key={day.date}
            date={day.date}
            completed={day.completed}
            color={color}
            onClick={() => onDayClick(day.date)}
            delay={index * 0.01}
          />
        ))}
      </div>
    </div>
  )
}

const CalendarDay = ({ date, completed, color, onClick, delay }) => {
  const dateObj = parseISO(date)
  const dayNumber = format(dateObj, 'd')
  const isToday = format(new Date(), 'yyyy-MM-dd') === date
  const isFuture = dateObj > new Date()
  
  return (
    <motion.button
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay, type: 'spring', stiffness: 400, damping: 25 }}
      onClick={onClick}
      disabled={isFuture}
      className="aspect-square rounded-2xl flex items-center justify-center relative overflow-hidden transition-all active:scale-95 disabled:opacity-20 border-2"
      style={{
        backgroundColor: completed ? color : '#2c2c2e',
        borderColor: completed ? color : (isToday ? '#a855f7' : 'transparent')
      }}
      whileTap={{ scale: isFuture ? 1 : 0.92 }}
    >
      <span
        className="text-lg font-bold relative z-10"
        style={{ color: completed ? '#ffffff' : '#98989f' }}
      >
        {dayNumber}
      </span>
      
      {completed && (
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 0.15 }}
          transition={{ type: 'spring', stiffness: 500, damping: 25 }}
          className="absolute inset-0 bg-white"
        />
      )}
      
      {isToday && (
        <div className="absolute bottom-2 left-1/2 transform -translate-x-1/2 w-1.5 h-1.5 rounded-full bg-habit-purple" />
      )}
    </motion.button>
  )
}

export default CalendarGrid
