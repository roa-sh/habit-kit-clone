import React, { useState } from "react";
import { AnimatePresence } from "framer-motion";
import { useHabits } from "./hooks/useHabits";
import HabitList from "./components/HabitList";
import HabitDetailModal from "./components/HabitDetailModal";
import NewHabitView from "./components/NewHabitView";
import CompactListSettings from "./components/CompactListSettings";

function App() {
  const { habits, initialLoading, createHabit, updateHabit, toggleCompletion } =
    useHabits();
  const [selectedHabit, setSelectedHabit] = useState(null);
  const [showNewHabit, setShowNewHabit] = useState(false);
  const [editingHabit, setEditingHabit] = useState(null);
  const [showSettings, setShowSettings] = useState(false);

  const handleToggleDay = async (externalId, date) => {
    try {
      await toggleCompletion(externalId, date);
    } catch (error) {
      console.error("Error toggling completion:", error);
    }
  };

  const handleCreateHabit = async (habitData) => {
    await createHabit(habitData);
    setShowNewHabit(false);
  };

  const handleUpdateHabit = async (externalId, habitData) => {
    await updateHabit(externalId, habitData);
    setEditingHabit(null);
  };

  const handleEditHabit = (habit) => {
    setEditingHabit(habit);
  };

  if (initialLoading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="w-12 h-12 border-4 border-habit-purple border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-dark-bg">
      <AnimatePresence mode="wait">
        {editingHabit ? (
          <NewHabitView
            key="edit-habit"
            onClose={() => setEditingHabit(null)}
            onSave={handleUpdateHabit}
            initialData={editingHabit}
            isEditing={true}
          />
        ) : showNewHabit ? (
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
        onEditHabit={handleEditHabit}
      />

      <CompactListSettings
        isOpen={showSettings}
        onClose={() => setShowSettings(false)}
      />
    </div>
  );
}

export default App;
