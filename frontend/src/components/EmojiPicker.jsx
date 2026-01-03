import React from 'react'
import { motion } from 'framer-motion'
import { X } from 'lucide-react'

const EMOJI_CATEGORIES = {
  'Activity': ['🏃', '🚴', '🏋️', '🧘', '🏊', '⛹️', '🤸', '🧗', '🏄', '🎯'],
  'Health': ['💊', '🩺', '🫀', '🧠', '🦷', '👁️', '💪', '🍎', '🥗', '💧'],
  'Learning': ['📚', '✏️', '📝', '🎓', '📖', '🧮', '🔬', '🎨', '🎭', '🎪'],
  'Work': ['💼', '💻', '⌨️', '🖥️', '📊', '📈', '📋', '✅', '🔨', '⚙️'],
  'Social': ['👥', '💬', '📞', '🤝', '❤️', '👨‍👩‍👧', '🎉', '🎊', '🎁', '🌟'],
  'Nature': ['🌱', '🌿', '🌻', '🌺', '🌹', '🌲', '🌳', '☀️', '🌙', '⭐'],
  'Food': ['🍎', '🥗', '🥑', '🍊', '🍇', '🥦', '🥕', '☕', '🫖', '🥤'],
  'Other': ['⚡', '🔥', '💎', '🎯', '🚀', '💫', '✨', '🎪', '🎭', '🎨']
}

const EmojiPicker = ({ currentEmoji, onSelect, onClose }) => {
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
        className="w-full bg-dark-card rounded-t-[32px] max-h-[85vh] overflow-hidden shadow-2xl"
        style={{ maxWidth: '428px', margin: '0 auto' }}
      >
        {/* Header */}
        <div className="sticky top-0 bg-dark-card z-10 border-b border-dark-border">
          <div className="flex items-center justify-between px-6 py-6">
            <h3 className="text-2xl font-bold text-dark-text-primary tracking-tight">
              Choose Icon
            </h3>
            <button
              onClick={onClose}
              className="w-11 h-11 rounded-full bg-dark-card-light hover:bg-dark-border transition-colors flex items-center justify-center active:scale-95"
            >
              <X className="w-6 h-6 text-dark-text-primary" strokeWidth={2.5} />
            </button>
          </div>
        </div>
        
        {/* Emoji Grid */}
        <div className="overflow-y-auto p-6 space-y-8" style={{ maxHeight: 'calc(85vh - 88px)' }}>
          {Object.entries(EMOJI_CATEGORIES).map(([category, emojis]) => (
            <div key={category}>
              <h4 className="text-xs font-bold text-dark-text-muted uppercase tracking-wide mb-4">
                {category}
              </h4>
              <div className="grid grid-cols-5 gap-3">
                {emojis.map((emoji) => (
                  <motion.button
                    key={emoji}
                    onClick={() => onSelect(emoji)}
                    whileTap={{ scale: 0.92 }}
                    className={`aspect-square rounded-2xl flex items-center justify-center text-3xl transition-all ${
                      emoji === currentEmoji
                        ? 'bg-habit-purple/30 shadow-lg'
                        : 'bg-dark-card-light hover:bg-dark-border'
                    }`}
                    style={emoji === currentEmoji ? {
                      boxShadow: '0 0 0 2px #a855f7'
                    } : {}}
                  >
                    {emoji}
                  </motion.button>
                ))}
              </div>
            </div>
          ))}
        </div>
      </motion.div>
    </motion.div>
  )
}

export default EmojiPicker
