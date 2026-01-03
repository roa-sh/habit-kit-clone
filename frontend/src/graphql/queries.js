import { gql } from '@apollo/client'
import { HABIT_WITH_LAST_N_DAYS, HABIT_WITH_LAST_5_DAYS, HABIT_FRAGMENT, COMPLETION_FRAGMENT, HABIT_STATS_FRAGMENT } from './fragments'

export const GET_HABITS = gql`
  ${HABIT_WITH_LAST_N_DAYS}
  
  query GetHabits($days: Int = 5) {
    habits {
      ...HabitWithLastNDays
    }
  }
`

export const GET_HABIT = gql`
  ${HABIT_FRAGMENT}
  ${HABIT_STATS_FRAGMENT}
  
  query GetHabit($externalId: String!) {
    habit(externalId: $externalId) {
      ...HabitFields
      stats {
        ...HabitStatsFields
      }
    }
  }
`

export const GET_HABIT_MONTH_DATA = gql`
  ${COMPLETION_FRAGMENT}
  
  query GetHabitMonthData($externalId: String!, $year: Int!, $month: Int!) {
    habitMonthData(externalId: $externalId, year: $year, month: $month) {
      ...CompletionFields
    }
  }
`

export const GET_CURRENT_SERVER_TIME = gql`
  query GetCurrentServerTime {
    currentServerTime
    currentServerDate
  }
`

export const GET_USER_SETTINGS = gql`
  query GetUserSettings {
    userSettings {
      id
      externalId
      compactDays
      showHabitNames
      createdAt
      updatedAt
    }
  }
`

