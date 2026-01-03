import React from 'react'
import { Plus } from 'lucide-react'
import { motion } from 'framer-motion'
import { useSettings } from '../hooks/useSettings'
import HabitCard from './HabitCard'

const HabitList = ({ habits, onHabitClick, onToggleDay, onAddHabit, onOpenSettings }) => {
  const { settings } = useSettings()
  
  return (
    <div className="min-h-screen bg-dark-bg">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-dark-bg/95 backdrop-blur-xl border-b border-dark-border">
        <div className="flex items-center justify-between px-6 py-5">
          <div>
            <h1 className="text-3xl font-bold text-dark-text-primary tracking-tight">
              Habit<span className="text-habit-purple">Kit</span>
            </h1>
            {/* Clickable Last N days button */}
            <button
              onClick={onOpenSettings}
              className="text-sm text-dark-text-secondary mt-1 hover:text-dark-text-primary transition-colors text-left font-medium px-3 py-1 -ml-3 rounded-lg hover:bg-dark-card-light"
            >
              Last {settings.compactDays} day{settings.compactDays !== 1 ? 's' : ''}
            </button>
          </div>
          
          <button
            onClick={onAddHabit}
            className="w-12 h-12 rounded-full bg-habit-purple flex items-center justify-center hover:bg-opacity-90 transition-all active:scale-95 shadow-lg"
            style={{ boxShadow: '0 4px 12px rgba(168, 85, 247, 0.4)' }}
          >
            <Plus className="w-6 h-6 text-white" strokeWidth={2.5} />
          </button>
        </div>
      </div>
      
      {/* Habits List */}
      <div className="px-5 py-6 space-y-4">
        {habits.length === 0 ? (
          <div className="text-center py-32">
            <div className="w-20 h-20 rounded-full bg-dark-card mx-auto mb-6 flex items-center justify-center">
              <Plus className="w-10 h-10 text-dark-text-muted" />
            </div>
            <p className="text-dark-text-primary text-xl font-semibold mb-2">
              No habits yet
            </p>
            <p className="text-dark-text-secondary text-base">
              Tap the + button to create your first habit
            </p>
          </div>
        ) : (
          habits.map((habit, index) => (
            <motion.div
              key={habit.externalId}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05, type: 'spring', stiffness: 300, damping: 30 }}
            >
              <HabitCard
                habit={habit}
                showName={settings.showHabitNames}
                compactDays={settings.compactDays}
                onCardClick={() => onHabitClick(habit)}
                onDayClick={(date) => onToggleDay(habit.externalId, date)}
              />
            </motion.div>
          ))
        )}
      </div>
    </div>
  )
}

export default HabitList

