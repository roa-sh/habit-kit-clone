import { useQuery, useMutation } from '@apollo/client'
import { GET_HABITS } from '../graphql/queries'
import { CREATE_HABIT, UPDATE_HABIT, DELETE_HABIT, TOGGLE_HABIT_COMPLETION, UPDATE_HABIT_COMPLETION } from '../graphql/mutations'

export const useHabits = () => {
  const { data, loading, error, refetch } = useQuery(GET_HABITS, {
    fetchPolicy: 'cache-and-network'
  })
  
  const [createHabitMutation, { loading: creating }] = useMutation(CREATE_HABIT, {
    update(cache, { data: { createHabit } }) {
      if (createHabit.habit && createHabit.errors.length === 0) {
        const existingHabits = cache.readQuery({ query: GET_HABITS })
        cache.writeQuery({
          query: GET_HABITS,
          data: {
            habits: [createHabit.habit, ...(existingHabits?.habits || [])]
          }
        })
      }
    }
  })
  
  const [updateHabitMutation, { loading: updating }] = useMutation(UPDATE_HABIT)
  const [deleteHabitMutation, { loading: deleting }] = useMutation(DELETE_HABIT, {
    update(cache, { data: { deleteHabit } }, { variables }) {
      if (deleteHabit.success) {
        const existingHabits = cache.readQuery({ query: GET_HABITS })
        cache.writeQuery({
          query: GET_HABITS,
          data: {
            habits: existingHabits.habits.filter(
              h => h.externalId !== variables.externalId
            )
          }
        })
      }
    }
  })
  
  const [toggleCompletionMutation, { loading: toggling }] = useMutation(
    TOGGLE_HABIT_COMPLETION
  )
  
  const [updateCompletionMutation, { loading: updatingCompletion }] = useMutation(
    UPDATE_HABIT_COMPLETION
  )
  
  const createHabit = async (habitData) => {
    try {
      const { data } = await createHabitMutation({
        variables: habitData
      })
      
      if (data.createHabit.errors.length > 0) {
        throw new Error(data.createHabit.errors.join(', '))
      }
      
      return data.createHabit.habit
    } catch (err) {
      console.error('Error creating habit:', err)
      throw err
    }
  }
  
  const updateHabit = async (externalId, habitData) => {
    try {
      const { data } = await updateHabitMutation({
        variables: {
          externalId,
          ...habitData
        }
      })
      
      if (data.updateHabit.errors.length > 0) {
        throw new Error(data.updateHabit.errors.join(', '))
      }
      
      return data.updateHabit.habit
    } catch (err) {
      console.error('Error updating habit:', err)
      throw err
    }
  }
  
  const deleteHabit = async (externalId) => {
    try {
      const { data } = await deleteHabitMutation({
        variables: { externalId }
      })
      
      if (data.deleteHabit.errors.length > 0) {
        throw new Error(data.deleteHabit.errors.join(', '))
      }
      
      return data.deleteHabit.success
    } catch (err) {
      console.error('Error deleting habit:', err)
      throw err
    }
  }
  
  const toggleCompletion = async (externalId, date = null) => {
    try {
      const { data } = await toggleCompletionMutation({
        variables: {
          externalId,
          date: date?.toString() || null
        }
      })
      
      if (data.toggleHabitCompletion.errors.length > 0) {
        throw new Error(data.toggleHabitCompletion.errors.join(', '))
      }
      
      return data.toggleHabitCompletion.habit
    } catch (err) {
      console.error('Error toggling completion:', err)
      throw err
    }
  }
  
  const updateCompletionState = async (externalId, state, date = null, notes = null) => {
    try {
      const { data } = await updateCompletionMutation({
        variables: {
          externalId,
          date: date?.toString() || null,
          state,
          notes
        }
      })
      
      if (data.updateHabitCompletion.errors.length > 0) {
        throw new Error(data.updateHabitCompletion.errors.join(', '))
      }
      
      return {
        habit: data.updateHabitCompletion.habit,
        completion: data.updateHabitCompletion.completion
      }
    } catch (err) {
      console.error('Error updating completion state:', err)
      throw err
    }
  }
  
  return {
    habits: data?.habits || [],
    loading: loading || creating || updating || deleting || toggling || updatingCompletion,
    error,
    refetch,
    createHabit,
    updateHabit,
    deleteHabit,
    toggleCompletion,
    updateCompletionState
  }
}

