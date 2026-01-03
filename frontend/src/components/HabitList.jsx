import React from 'react'
import { Plus } from 'lucide-react'
import { motion } from 'framer-motion'
import { useSettings } from '../hooks/useSettings'
import { format, parseISO } from 'date-fns'
import HabitCard from './HabitCard'

const HabitList = ({ habits, onHabitClick, onToggleDay, onAddHabit, onOpenSettings }) => {
  const { settings } = useSettings()
  
  // Get the day header dates from the first habit (or generate them)
  const headerDays = habits.length > 0 && habits[0].lastNDays 
    ? habits[0].lastNDays.slice(-settings.compactDays)
    : []
  
  return (
    <div className="min-h-screen bg-ios-bg">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-ios-bg/95 backdrop-blur-xl border-b border-ios-border">
        {/* First row: Title and buttons */}
        <div className="flex items-center justify-between px-5 py-4">
          <h1 className="text-3xl font-bold text-ios-text-primary tracking-tight">
            Habit<span className="text-habit-purple">Kit</span>
          </h1>
          
          <button
            onClick={onAddHabit}
            className="w-11 h-11 rounded-full bg-habit-purple flex items-center justify-center hover:opacity-90 transition-all active:scale-95"
            style={{ boxShadow: '0 4px 12px rgba(168, 85, 247, 0.4)' }}
          >
            <Plus className="w-5 h-5 text-white" strokeWidth={2.5} />
          </button>
        </div>
        
        {/* Second row: Last N days button and day header */}
        <div className="flex items-start justify-between px-5 pb-3">
          <button
            onClick={onOpenSettings}
            className="text-sm text-ios-text-primary bg-ios-card hover:bg-ios-card-secondary transition-colors font-medium px-4 py-2 rounded-full"
          >
            Last {settings.compactDays} day{settings.compactDays !== 1 ? 's' : ''}
          </button>
          
          {/* Global Day Header - right side - plain text only with proper spacing */}
          {/* Adding pr-3 to match the internal padding of habit cards for perfect alignment */}
          {habits.length > 0 && (
            <div className="flex gap-1 pr-3">
              {headerDays.map((day) => {
                const dateObj = parseISO(day.date)
                const dayAbbrev = format(dateObj, 'EEE').substring(0, 2) // Tu, We, Th
                const dayNumber = format(dateObj, 'd')
                return (
                  <div key={day.date} className="w-6 flex flex-col items-center gap-0.5">
                    <span className="text-[9px] font-semibold text-ios-text-muted capitalize leading-none">
                      {dayAbbrev}
                    </span>
                    <span className="text-xs font-bold text-ios-text-secondary leading-none">
                      {dayNumber}
                    </span>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </div>
      
      {/* Habits List */}
      <div className="px-5 py-4 space-y-2">
        {habits.length === 0 ? (
          <div className="text-center py-32">
            <div className="w-20 h-20 rounded-full bg-ios-card mx-auto mb-6 flex items-center justify-center">
              <Plus className="w-10 h-10 text-ios-text-muted" />
            </div>
            <p className="text-xl font-semibold text-ios-text-primary mb-2">
              No habits yet
            </p>
            <p className="text-base text-ios-text-secondary">
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
