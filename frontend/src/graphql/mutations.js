import { gql } from '@apollo/client'
import { HABIT_WITH_LAST_5_DAYS, COMPLETION_FRAGMENT } from './fragments'

export const CREATE_HABIT = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  mutation CreateHabit(
    $name: String!
    $description: String
    $emoji: String
    $color: String
    $streakGoal: StreakGoalEnum
  ) {
    createHabit(
      input: {
        name: $name
        description: $description
        emoji: $emoji
        color: $color
        streakGoal: $streakGoal
      }
    ) {
      habit {
        ...HabitWithLast5Days
      }
      errors
    }
  }
`

export const UPDATE_HABIT = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  mutation UpdateHabit(
    $externalId: String!
    $name: String
    $description: String
    $emoji: String
    $color: String
    $streakGoal: StreakGoalEnum
  ) {
    updateHabit(
      input: {
        externalId: $externalId
        name: $name
        description: $description
        emoji: $emoji
        color: $color
        streakGoal: $streakGoal
      }
    ) {
      habit {
        ...HabitWithLast5Days
      }
      errors
    }
  }
`

export const DELETE_HABIT = gql`
  mutation DeleteHabit($externalId: String!) {
    deleteHabit(input: { externalId: $externalId }) {
      success
      errors
    }
  }
`

export const TOGGLE_HABIT_COMPLETION = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  mutation ToggleHabitCompletion($externalId: String!, $date: String) {
    toggleHabitCompletion(input: { externalId: $externalId, date: $date }) {
      habit {
        ...HabitWithLast5Days
      }
      newState
      errors
    }
  }
`

export const UPDATE_HABIT_COMPLETION = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  ${COMPLETION_FRAGMENT}
  
  mutation UpdateHabitCompletion(
    $externalId: String!
    $date: String
    $state: CompletionStateEnum!
    $notes: String
  ) {
    updateHabitCompletion(
      input: {
        externalId: $externalId
        date: $date
        state: $state
        notes: $notes
      }
    ) {
      habit {
        ...HabitWithLast5Days
      }
      completion {
        ...CompletionFields
      }
      errors
    }
  }
`

export const UPDATE_USER_SETTINGS = gql`
  mutation UpdateUserSettings($compactDays: Int, $showHabitNames: Boolean) {
    updateUserSettings(
      input: {
        compactDays: $compactDays
        showHabitNames: $showHabitNames
      }
    ) {
      userSettings {
        id
        externalId
        compactDays
        showHabitNames
        updatedAt
      }
      errors
    }
  }
`

