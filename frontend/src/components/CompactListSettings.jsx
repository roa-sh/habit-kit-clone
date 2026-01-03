import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X } from 'lucide-react'
import { useSettings } from '../hooks/useSettings'

const CompactListSettings = ({ isOpen, onClose }) => {
  const { settings, updateSettings } = useSettings()
  const [localCompactDays, setLocalCompactDays] = useState(settings.compactDays)
  const [localShowNames, setLocalShowNames] = useState(settings.showHabitNames)
  
  useEffect(() => {
    if (settings) {
      setLocalCompactDays(settings.compactDays)
      setLocalShowNames(settings.showHabitNames)
    }
  }, [settings])
  
  const handleDaysChange = async (days) => {
    setLocalCompactDays(days)
    try {
      await updateSettings(days, null)
    } catch (error) {
      console.error('Error updating compact days:', error)
    }
  }
  
  const handleNamesToggle = async (show) => {
    setLocalShowNames(show)
    try {
      await updateSettings(null, show)
    } catch (error) {
      console.error('Error updating show names:', error)
    }
  }
  
  if (!isOpen) return null
  
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 z-40"
          />
          
          {/* Modal */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 35, stiffness: 350 }}
            className="fixed inset-x-0 bottom-0 z-50 bg-ios-card rounded-t-[32px] overflow-hidden"
            style={{
              maxWidth: '428px',
              margin: '0 auto',
              maxHeight: '85vh'
            }}
          >
            {/* Header */}
            <div className="flex items-center justify-between px-6 py-6 border-b border-ios-border">
              <h2 className="text-2xl font-bold text-ios-text-primary tracking-tight">
                Display Settings
              </h2>
              <button
                onClick={onClose}
                className="w-11 h-11 rounded-full bg-ios-card-secondary hover:bg-ios-border transition-colors flex items-center justify-center active:scale-95"
              >
                <X className="w-6 h-6 text-ios-text-primary" strokeWidth={2.5} />
              </button>
            </div>
            
            {/* Content */}
            <div className="p-6 space-y-8 pb-10">
              {/* Days Selection */}
              <div>
                <h3 className="text-base font-semibold text-ios-text-primary mb-2">
                  Number of Days
                </h3>
                <p className="text-sm text-ios-text-secondary mb-4">
                  Configure the amount of days to display in the compact list
                </p>
                
                <div className="grid grid-cols-7 gap-3">
                  {[1, 2, 3, 4, 5, 6, 7].map((days) => (
                    <motion.button
                      key={days}
                      onClick={() => handleDaysChange(days)}
                      whileTap={{ scale: 0.92 }}
                      className={`aspect-square rounded-2xl font-bold text-lg transition-all ${
                        localCompactDays === days
                          ? 'bg-habit-purple text-white'
                          : 'bg-ios-card-secondary text-ios-text-primary border-2 border-ios-border hover:border-ios-border-light'
                      }`}
                      style={localCompactDays === days ? {
                        boxShadow: '0 4px 12px rgba(168, 85, 247, 0.4)'
                      } : {}}
                    >
                      {days}
                    </motion.button>
                  ))}
                </div>
              </div>
              
              {/* Name Visibility Toggle */}
              <div>
                <h3 className="text-base font-semibold text-ios-text-primary mb-2">
                  Habit Names
                </h3>
                <p className="text-sm text-ios-text-secondary mb-4">
                  Configure whether the habit names will be hidden or not
                </p>
                
                <div className="bg-ios-card-secondary rounded-2xl p-5">
                  <div className="flex items-center justify-between">
                    <span className="text-base font-semibold text-ios-text-primary">
                      Show habit names
                    </span>
                    <button
                      onClick={() => handleNamesToggle(!localShowNames)}
                      className={`relative w-14 h-8 rounded-full transition-all ${
                        localShowNames ? 'bg-habit-purple' : 'bg-ios-border'
                      }`}
                    >
                      <div
                        className={`absolute top-1 left-1 w-6 h-6 rounded-full bg-white transition-transform shadow-md ${
                          localShowNames ? 'translate-x-6' : 'translate-x-0'
                        }`}
                      />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default CompactListSettings
