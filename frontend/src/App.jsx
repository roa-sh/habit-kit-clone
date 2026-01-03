import React, { useState } from 'react'
import { AnimatePresence } from 'framer-motion'
import { useHabits } from './hooks/useHabits'
import HabitList from './components/HabitList'
import HabitDetailModal from './components/HabitDetailModal'
import NewHabitView from './components/NewHabitView'
import CompactListSettings from './components/CompactListSettings'

function App() {
  const { habits, loading, createHabit, toggleCompletion, refetch } = useHabits()
  const [selectedHabit, setSelectedHabit] = useState(null)
  const [showNewHabit, setShowNewHabit] = useState(false)
  const [showSettings, setShowSettings] = useState(false)
  
  const handleToggleDay = async (externalId, date) => {
    try {
      await toggleCompletion(externalId, date)
      await refetch() // Force refetch to update the UI
    } catch (error) {
      console.error('Error toggling completion:', error)
    }
  }
  
  const handleCreateHabit = async (habitData) => {
    await createHabit(habitData)
    setShowNewHabit(false)
  }
  
  if (loading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="w-12 h-12 border-4 border-habit-purple border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }
  
  return (
    <div className="min-h-screen bg-dark-bg">
      <AnimatePresence mode="wait">
        {showNewHabit ? (
          <NewHabitView
            key="new-habit"
            onClose={() => setShowNewHabit(false)}
            onSave={handleCreateHabit}
          />
        ) : (
          <HabitList
            key="habit-list"
            habits={habits}
            onHabitClick={setSelectedHabit}
            onToggleDay={handleToggleDay}
            onAddHabit={() => setShowNewHabit(true)}
            onOpenSettings={() => setShowSettings(true)}
          />
        )}
      </AnimatePresence>
      
      <HabitDetailModal
        habit={selectedHabit}
        isOpen={!!selectedHabit}
        onClose={() => setSelectedHabit(null)}
        onToggleDay={handleToggleDay}
      />
      
      <CompactListSettings
        isOpen={showSettings}
        onClose={() => setShowSettings(false)}
      />
    </div>
  )
}

export default App
