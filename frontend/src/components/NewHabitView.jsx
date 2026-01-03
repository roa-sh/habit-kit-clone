import React, { useState } from 'react'
import { motion } from 'framer-motion'
import { X, ChevronRight } from 'lucide-react'
import EmojiPicker from './EmojiPicker'
import ColorPicker from './ColorPicker'

const STREAK_GOALS = [
  { value: 'NONE', label: 'None' },
  { value: 'DAILY', label: 'Daily' },
  { value: 'WEEKLY', label: 'Weekly' },
  { value: 'MONTHLY', label: 'Monthly' }
]

const NewHabitView = ({ onClose, onSave, initialData = null }) => {
  const [formData, setFormData] = useState({
    name: initialData?.name || '',
    description: initialData?.description || '',
    emoji: initialData?.emoji || '⚡',
    color: initialData?.color || '#a855f7',
    streakGoal: initialData?.streakGoal || 'NONE'
  })
  
  const [showEmojiPicker, setShowEmojiPicker] = useState(false)
  const [showColorPicker, setShowColorPicker] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  
  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!formData.name.trim()) {
      alert('Please enter a habit name')
      return
    }
    
    setIsSaving(true)
    try {
      await onSave(formData)
      onClose()
    } catch (error) {
      alert('Error saving habit: ' + error.message)
    } finally {
      setIsSaving(false)
    }
  }
  
  return (
    <motion.div
      initial={{ x: '100%' }}
      animate={{ x: 0 }}
      exit={{ x: '100%' }}
      transition={{ type: 'spring', damping: 30, stiffness: 300 }}
      className="fixed inset-0 bg-ios-bg z-50 overflow-y-auto"
      style={{ maxWidth: '428px', margin: '0 auto' }}
    >
      {/* Header */}
      <div className="sticky top-0 bg-ios-bg/95 backdrop-blur-xl border-b border-ios-border z-10">
        <div className="flex items-center justify-between px-6 py-5">
          <button
            onClick={onClose}
            className="w-11 h-11 rounded-full bg-ios-card-secondary flex items-center justify-center hover:bg-ios-border transition-colors active:scale-95"
          >
            <X className="w-6 h-6 text-ios-text-primary" strokeWidth={2.5} />
          </button>
          <h1 className="text-2xl font-bold text-ios-text-primary tracking-tight">
            New Habit
          </h1>
          <div className="w-11" />
        </div>
      </div>
      
      {/* Form */}
      <form onSubmit={handleSubmit} className="p-6 space-y-6">
        {/* Emoji Selector */}
        <div className="flex flex-col items-center py-6">
          <button
            type="button"
            onClick={() => setShowEmojiPicker(true)}
            className="w-28 h-28 rounded-3xl flex items-center justify-center text-6xl transition-all active:scale-95"
            style={{ backgroundColor: formData.color + '20' }}
          >
            {formData.emoji}
          </button>
          <p className="text-sm text-ios-text-secondary mt-4 font-medium">
            Tap to change icon
          </p>
        </div>
        
        {/* Name Input */}
        <div>
          <label className="block text-sm font-semibold text-ios-text-primary mb-3">
            Name
          </label>
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
            placeholder="e.g. Morning Run"
            className="w-full px-5 py-4 bg-ios-card border-2 border-ios-border rounded-2xl text-ios-text-primary text-base placeholder-ios-text-muted focus:border-habit-purple transition-colors"
            autoFocus
          />
        </div>
        
        {/* Description Input */}
        <div>
          <label className="block text-sm font-semibold text-ios-text-primary mb-3">
            Description
          </label>
          <textarea
            value={formData.description}
            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
            placeholder="Optional notes about this habit"
            rows={3}
            className="w-full px-5 py-4 bg-ios-card border-2 border-ios-border rounded-2xl text-ios-text-primary text-base placeholder-ios-text-muted focus:border-habit-purple transition-colors resize-none"
          />
        </div>
        
        {/* Color Picker */}
        <div>
          <label className="block text-sm font-semibold text-ios-text-primary mb-3">
            Color
          </label>
          <button
            type="button"
            onClick={() => setShowColorPicker(true)}
            className="w-full px-5 py-4 bg-ios-card border-2 border-ios-border rounded-2xl flex items-center justify-between hover:border-habit-purple transition-colors active:scale-98"
          >
            <span className="text-ios-text-primary font-medium">Choose color</span>
            <div className="flex items-center gap-3">
              <div
                className="w-8 h-8 rounded-xl shadow-lg"
                style={{ backgroundColor: formData.color }}
              />
              <ChevronRight className="w-5 h-5 text-ios-text-secondary" />
            </div>
          </button>
        </div>
        
        {/* Streak Goal */}
        <div>
          <label className="block text-sm font-semibold text-ios-text-primary mb-3">
            Streak Goal
          </label>
          <div className="grid grid-cols-2 gap-3">
            {STREAK_GOALS.map(goal => (
              <button
                key={goal.value}
                type="button"
                onClick={() => setFormData(prev => ({ ...prev, streakGoal: goal.value }))}
                className={`px-5 py-4 rounded-2xl font-semibold transition-all active:scale-95 ${
                  formData.streakGoal === goal.value
                    ? 'bg-habit-purple text-white'
                    : 'bg-ios-card text-ios-text-primary border-2 border-ios-border hover:border-ios-border-light'
                }`}
                style={formData.streakGoal === goal.value ? {
                  boxShadow: '0 4px 12px rgba(168, 85, 247, 0.4)'
                } : {}}
              >
                {goal.label}
              </button>
            ))}
          </div>
        </div>
        
        {/* Save Button */}
        <button
          type="submit"
          disabled={isSaving || !formData.name.trim()}
          className="w-full py-5 bg-habit-purple text-white text-lg font-bold rounded-2xl hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed active:scale-98 mt-4"
          style={{ boxShadow: '0 4px 12px rgba(168, 85, 247, 0.4)' }}
        >
          {isSaving ? 'Saving...' : 'Create Habit'}
        </button>
      </form>
      
      {/* Modals */}
      {showEmojiPicker && (
        <EmojiPicker
          currentEmoji={formData.emoji}
          onSelect={(emoji) => {
            setFormData(prev => ({ ...prev, emoji }))
            setShowEmojiPicker(false)
          }}
          onClose={() => setShowEmojiPicker(false)}
        />
      )}
      
      {showColorPicker && (
        <ColorPicker
          currentColor={formData.color}
          onSelect={(color) => {
            setFormData(prev => ({ ...prev, color }))
            setShowColorPicker(false)
          }}
          onClose={() => setShowColorPicker(false)}
        />
      )}
    </motion.div>
  )
}

export default NewHabitView
