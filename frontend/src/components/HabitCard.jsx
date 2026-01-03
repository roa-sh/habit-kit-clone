import React, { useMemo } from 'react'
import { motion } from 'framer-motion'

const HabitCard = ({ habit, showName = true, compactDays = 5, onCardClick, onDayClick }) => {
  const displayDays = useMemo(() => {
    if (!habit.lastNDays) return []
    return habit.lastNDays.slice(-compactDays)
  }, [habit.lastNDays, compactDays])
  
  return (
    <div 
      className="bg-ios-card rounded-2xl border-l-[5px] hover:shadow-lg transition-all cursor-pointer"
      style={{ borderLeftColor: habit.color }}
    >
      <div className="py-1.5 px-2 flex items-center gap-3">
        {/* Left side: Emoji and Habit Info - flex-shrink allows it to compress when squares overflow */}
        <div 
          className="flex items-center gap-2 flex-1 min-w-0 overflow-hidden"
          onClick={onCardClick}
        >
          <div 
            className="w-7 h-7 rounded-lg flex items-center justify-center text-lg flex-shrink-0"
            style={{ backgroundColor: habit.color + '20' }}
          >
            {habit.emoji}
          </div>
          
          {showName && (
            <div className="flex-1 min-w-0 overflow-hidden">
              {/* Habit name in a contained rounded box with colored background */}
              <div 
                className="inline-block px-3 py-1 rounded-xl max-w-full"
                style={{ backgroundColor: habit.color + '15' }}
              >
                <h3 className="text-sm font-semibold text-ios-text-primary truncate leading-tight">
                  {habit.name}
                </h3>
              </div>
            </div>
          )}
        </div>
        
        {/* Right side: Day squares with proper spacing to align with header */}
        <div className="flex gap-1 flex-shrink-0">
          {displayDays.map((day) => (
            <motion.button
              key={day.date}
              onClick={(e) => {
                e.stopPropagation()
                onDayClick(day.date)
              }}
              className="w-6 h-6 rounded-md flex items-center justify-center relative overflow-hidden transition-all active:scale-95"
              style={{
                backgroundColor: day.completed ? habit.color : habit.color + '20',
                border: 'none'
              }}
              whileTap={{ scale: 0.92 }}
            >
              {/* Subtle overlay for completed state */}
              {day.completed && (
                <motion.div
                  initial={{ scale: 0, opacity: 0 }}
                  animate={{ scale: 1, opacity: 0.15 }}
                  className="absolute inset-0 bg-white"
                />
              )}
            </motion.button>
          ))}
        </div>
      </div>
    </div>
  )
}

export default HabitCard
