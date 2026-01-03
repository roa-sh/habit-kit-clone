import React, { useMemo } from 'react'
import { motion } from 'framer-motion'

const HabitCard = ({ habit, showName = true, compactDays = 5, onCardClick, onDayClick }) => {
  const displayDays = useMemo(() => {
    if (!habit.last5Days) return []
    return habit.last5Days.slice(-compactDays)
  }, [habit.last5Days, compactDays])
  
  return (
    <div 
      className="bg-ios-card rounded-2xl border-l-[5px] hover:shadow-lg transition-all cursor-pointer"
      style={{ borderLeftColor: habit.color }}
    >
      <div className="py-2 px-3 flex items-center justify-between gap-3">
        {/* Left side: Emoji and Habit Info */}
        <div className="flex items-center gap-3 flex-1 min-w-0" onClick={onCardClick}>
          <div 
            className="w-11 h-11 rounded-xl flex items-center justify-center text-2xl flex-shrink-0"
            style={{ backgroundColor: habit.color + '20' }}
          >
            {habit.emoji}
          </div>
          
          {showName && (
            <div className="flex-1 min-w-0">
              <h3 className="text-base font-semibold text-ios-text-primary truncate leading-tight">
                {habit.name}
              </h3>
              {habit.description && (
                <p className="text-xs text-ios-text-secondary truncate leading-tight">
                  {habit.description}
                </p>
              )}
            </div>
          )}
        </div>
        
        {/* Right side: Day squares (no numbers - just status indicators) */}
        <div className="flex gap-1 flex-shrink-0">
          {displayDays.map((day) => (
            <motion.button
              key={day.date}
              onClick={(e) => {
                e.stopPropagation()
                onDayClick(day.date)
              }}
              className="w-8 h-8 rounded-xl flex items-center justify-center relative overflow-hidden transition-all active:scale-95 border-2"
              style={{
                backgroundColor: day.completed ? habit.color : '#2c2c2e',
                borderColor: day.completed ? habit.color : 'transparent'
              }}
              whileTap={{ scale: 0.92 }}
            >
              {/* No number - just empty box or colored box */}
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
