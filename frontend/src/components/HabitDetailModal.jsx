import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X, ChevronLeft, ChevronRight } from 'lucide-react'
import { useCalendar } from '../hooks/useCalendar'
import { useQuery } from '@apollo/client'
import { GET_HABIT_MONTH_DATA } from '../graphql/queries'
import CalendarGrid from './CalendarGrid'

const HabitDetailModal = ({ habit, isOpen, onClose, onToggleDay }) => {
  const [monthData, setMonthData] = useState([])
  const calendar = useCalendar()
  
  const { data, loading, refetch } = useQuery(GET_HABIT_MONTH_DATA, {
    variables: {
      externalId: habit?.externalId,
      year: calendar.year,
      month: calendar.month
    },
    skip: !isOpen || !habit,
    fetchPolicy: 'network-only'
  })
  
  useEffect(() => {
    if (data?.habitMonthData) {
      setMonthData(data.habitMonthData)
    }
  }, [data])
  
  useEffect(() => {
    if (isOpen && habit) {
      refetch()
    }
  }, [isOpen, habit, calendar.year, calendar.month, refetch])
  
  const handleDayClick = async (date) => {
    await onToggleDay(habit.externalId, date)
    refetch()
  }
  
  if (!habit) return null
  
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop with Blur */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-md z-40"
          />
          
          {/* Modal Content */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed inset-x-0 bottom-0 z-50 bg-dark-card rounded-t-3xl max-h-[90vh] overflow-hidden"
            style={{
              maxWidth: '428px',
              margin: '0 auto',
              left: '50%',
              transform: 'translateX(-50%)'
            }}
          >
            {/* Header */}
            <div className="sticky top-0 bg-dark-card z-10">
              <div className="flex items-start justify-between px-6 py-6 border-b border-dark-border">
                <div className="flex items-start gap-4">
                  <div 
                    className="w-16 h-16 rounded-2xl flex items-center justify-center text-4xl flex-shrink-0"
                    style={{ backgroundColor: habit.color + '20' }}
                  >
                    {habit.emoji}
                  </div>
                  <div className="flex-1 pt-1">
                    <h2 className="text-2xl font-bold text-dark-text-primary leading-tight">
                      {habit.name}
                    </h2>
                    {habit.description && (
                      <p className="text-sm text-dark-text-secondary mt-1.5 leading-relaxed">
                        {habit.description}
                      </p>
                    )}
                  </div>
                </div>
                <button
                  onClick={onClose}
                  className="w-11 h-11 rounded-full bg-dark-card-light hover:bg-dark-border transition-colors flex items-center justify-center flex-shrink-0"
                >
                  <X className="w-6 h-6 text-dark-text-primary" strokeWidth={2.5} />
                </button>
              </div>
              
              {/* Streak Info */}
              <div className="px-6 py-6 border-b border-dark-border bg-dark-bg/30">
                <div className="flex gap-6">
                  <div className="flex-1 text-center">
                    <p className="text-xs font-semibold text-dark-text-secondary uppercase tracking-wide mb-2">
                      Current Streak
                    </p>
                    <p className="text-3xl font-bold text-dark-text-primary">
                      {habit.currentStreak}
                    </p>
                    <p className="text-xs text-dark-text-muted mt-1">
                      {habit.currentStreak === 1 ? 'day' : 'days'}
                    </p>
                  </div>
                  <div className="w-px bg-dark-border" />
                  <div className="flex-1 text-center">
                    <p className="text-xs font-semibold text-dark-text-secondary uppercase tracking-wide mb-2">
                      Longest Streak
                    </p>
                    <p className="text-3xl font-bold" style={{ color: habit.color }}>
                      {habit.longestStreak}
                    </p>
                    <p className="text-xs text-dark-text-muted mt-1">
                      {habit.longestStreak === 1 ? 'day' : 'days'}
                    </p>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Calendar Navigation */}
            <div className="flex items-center justify-between px-6 py-5 bg-dark-bg/20">
              <button
                onClick={calendar.goToPreviousMonth}
                className="w-11 h-11 rounded-full bg-dark-card-light hover:bg-dark-border transition-colors flex items-center justify-center active:scale-95"
              >
                <ChevronLeft className="w-6 h-6 text-dark-text-primary" strokeWidth={2.5} />
              </button>
              
              <h3 className="text-xl font-bold text-dark-text-primary tracking-tight">
                {calendar.monthName} {calendar.year}
              </h3>
              
              <button
                onClick={calendar.goToNextMonth}
                className="w-11 h-11 rounded-full bg-dark-card-light hover:bg-dark-border transition-colors flex items-center justify-center active:scale-95"
              >
                <ChevronRight className="w-6 h-6 text-dark-text-primary" strokeWidth={2.5} />
              </button>
            </div>
            
            {/* Calendar Grid */}
            <div className="px-6 pb-8 pt-2 overflow-y-auto">
              {loading ? (
                <div className="flex items-center justify-center py-24">
                  <div className="w-10 h-10 border-4 border-habit-purple border-t-transparent rounded-full animate-spin" />
                </div>
              ) : (
                <CalendarGrid
                  days={monthData}
                  color={habit.color}
                  onDayClick={handleDayClick}
                />
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default HabitDetailModal

