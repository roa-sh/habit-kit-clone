import { useQuery, useMutation } from '@apollo/client'
import { GET_USER_SETTINGS } from '../graphql/queries'
import { UPDATE_USER_SETTINGS } from '../graphql/mutations'

export const useSettings = () => {
  const { data, loading, error } = useQuery(GET_USER_SETTINGS, {
    fetchPolicy: 'cache-and-network'
  })
  
  const [updateSettingsMutation, { loading: updating }] = useMutation(UPDATE_USER_SETTINGS)
  
  const updateSettings = async (compactDays = null, showHabitNames = null) => {
    try {
      const variables = {}
      if (compactDays !== null) variables.compactDays = compactDays
      if (showHabitNames !== null) variables.showHabitNames = showHabitNames
      
      const { data } = await updateSettingsMutation({ variables })
      
      if (data.updateUserSettings.errors.length > 0) {
        throw new Error(data.updateUserSettings.errors.join(', '))
      }
      
      return data.updateUserSettings.userSettings
    } catch (err) {
      console.error('Error updating settings:', err)
      throw err
    }
  }
  
  return {
    settings: data?.userSettings || { compactDays: 5, showHabitNames: true },
    loading: loading || updating,
    error,
    updateSettings
  }
}

