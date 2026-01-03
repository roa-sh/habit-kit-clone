import React from 'react'
import { motion } from 'framer-motion'
import { format, parseISO } from 'date-fns'

const DaySquare = ({ date, completed, color, onClick }) => {
  const dateObj = parseISO(date)
  const dayLabel = format(dateObj, 'EEE')
  const dayNumber = format(dateObj, 'd')
  
  return (
    <motion.button
      onClick={onClick}
      className="flex-1 aspect-square rounded-2xl flex flex-col items-center justify-center gap-0.5 relative overflow-hidden transition-all active:scale-95 border-2"
      style={{
        backgroundColor: completed ? color : '#2c2c2e',
        borderColor: completed ? color : 'transparent'
      }}
      whileTap={{ scale: 0.92 }}
    >
      <span 
        className="text-[10px] font-semibold tracking-tight uppercase"
        style={{ color: completed ? '#ffffff' : '#636366' }}
      >
        {dayLabel}
      </span>
      <span 
        className="text-xl font-bold"
        style={{ color: completed ? '#ffffff' : '#98989f' }}
      >
        {dayNumber}
      </span>
      
      {completed && (
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 0.15 }}
          className="absolute inset-0 bg-white"
        />
      )}
    </motion.button>
  )
}

export default DaySquare
