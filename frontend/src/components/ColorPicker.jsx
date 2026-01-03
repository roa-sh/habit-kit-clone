import React from 'react'
import { motion } from 'framer-motion'
import { X, Check } from 'lucide-react'

const COLORS = [
  { name: 'Purple', value: '#a855f7' },
  { name: 'Red', value: '#ef4444' },
  { name: 'Blue', value: '#3b82f6' },
  { name: 'Green', value: '#10b981' },
  { name: 'Yellow', value: '#f59e0b' },
  { name: 'Pink', value: '#ec4899' },
  { name: 'Indigo', value: '#6366f1' },
  { name: 'Teal', value: '#14b8a6' },
  { name: 'Orange', value: '#f97316' },
  { name: 'Gray', value: '#6b7280' }
]

const ColorPicker = ({ currentColor, onSelect, onClose }) => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/60 backdrop-blur-md z-[60] flex items-end"
      onClick={onClose}
    >
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ type: 'spring', damping: 35, stiffness: 350 }}
        onClick={(e) => e.stopPropagation()}
        className="w-full bg-ios-card rounded-t-[32px] overflow-hidden"
        style={{ maxWidth: '428px', margin: '0 auto' }}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-6 border-b border-ios-border">
          <h3 className="text-2xl font-bold text-ios-text-primary tracking-tight">
            Choose Color
          </h3>
          <button
            onClick={onClose}
            className="w-11 h-11 rounded-full bg-ios-card-secondary hover:bg-ios-border transition-colors flex items-center justify-center active:scale-95"
          >
            <X className="w-6 h-6 text-ios-text-primary" strokeWidth={2.5} />
          </button>
        </div>
        
        {/* Color Grid */}
        <div className="px-6 py-8 pb-10">
          <div className="grid grid-cols-5 gap-5">
            {COLORS.map((color) => (
              <motion.button
                key={color.value}
                onClick={() => onSelect(color.value)}
                whileTap={{ scale: 0.92 }}
                className="aspect-square rounded-3xl relative flex items-center justify-center shadow-lg transition-all"
                style={{ 
                  backgroundColor: color.value,
                  boxShadow: currentColor === color.value 
                    ? `0 0 0 3px ${color.value}, 0 0 0 5px #000` 
                    : `0 4px 8px ${color.value}40`
                }}
              >
                {currentColor === color.value && (
                  <motion.div
                    initial={{ scale: 0, rotate: -180 }}
                    animate={{ scale: 1, rotate: 0 }}
                    transition={{ type: 'spring', stiffness: 400, damping: 20 }}
                    className="absolute inset-0 flex items-center justify-center"
                  >
                    <Check className="w-10 h-10 text-white drop-shadow-2xl" strokeWidth={3.5} />
                  </motion.div>
                )}
              </motion.button>
            ))}
          </div>
        </div>
      </motion.div>
    </motion.div>
  )
}

export default ColorPicker
