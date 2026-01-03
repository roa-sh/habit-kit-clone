import { gql } from '@apollo/client'

export const HABIT_FRAGMENT = gql`
  fragment HabitFields on Habit {
    id
    externalId
    name
    description
    emoji
    color
    streakGoal
    currentStreak
    longestStreak
    createdAt
    updatedAt
  }
`

export const COMPLETION_FRAGMENT = gql`
  fragment CompletionFields on Completion {
    date
    state
    completed
    completedAt
    notes
  }
`

export const HABIT_WITH_LAST_5_DAYS = gql`
  ${HABIT_FRAGMENT}
  ${COMPLETION_FRAGMENT}
  
  fragment HabitWithLast5Days on Habit {
    ...HabitFields
    last5Days {
      ...CompletionFields
    }
  }
`

export const HABIT_STATS_FRAGMENT = gql`
  fragment HabitStatsFields on HabitStats {
    totalCompletions
    totalSkipped
    totalFailed
    currentStreak
    longestStreak
  }
`

