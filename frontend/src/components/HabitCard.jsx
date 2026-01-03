import React, { useMemo } from 'react'
import { motion } from 'framer-motion'
import DaySquare from './DaySquare'

const HabitCard = ({ habit, showName = true, compactDays = 5, onCardClick, onDayClick }) => {
  // Generate the correct number of days dynamically
  const displayDays = useMemo(() => {
    if (!habit.last5Days) return []
    
    // Get the last N days from the habit data
    return habit.last5Days.slice(-compactDays)
  }, [habit.last5Days, compactDays])
  
  return (
    <div
      className="bg-dark-card rounded-3xl border-2 overflow-hidden"
      style={{ 
        borderColor: habit.color,
        borderLeftWidth: '6px'
      }}
    >
      {/* Habit Info - Clickable to open detail */}
      <div
        onClick={onCardClick}
        className="flex items-center gap-4 px-5 py-4 cursor-pointer active:opacity-70 transition-opacity"
      >
        <div 
          className="w-14 h-14 rounded-2xl flex items-center justify-center text-3xl"
          style={{ backgroundColor: habit.color + '20' }}
        >
          {habit.emoji}
        </div>
        
        {/* Conditionally show habit name and description */}
        {showName && (
          <div className="flex-1 min-w-0">
            <h3 className="text-dark-text-primary font-semibold text-lg truncate">
              {habit.name}
            </h3>
            {habit.description && (
              <p className="text-dark-text-secondary text-sm truncate mt-1">
                {habit.description}
              </p>
            )}
          </div>
        )}
      </div>
      
      {/* Last N Days Grid */}
      <div className="flex gap-2 px-5 pb-5">
        {displayDays.map((day) => (
          <DaySquare
            key={day.date}
            date={day.date}
            completed={day.completed}
            color={habit.color}
            onClick={(e) => {
              e.stopPropagation()
              onDayClick(day.date)
            }}
          />
        ))}
      </div>
    </div>
  )
}

export default HabitCard

