class CreateCompletionStates < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE completion_state AS ENUM (
        'not_started',
        'in_progress', 
        'completed',
        'skipped',
        'failed'
      );
    SQL
  end
  
  def down
    execute <<-SQL
      DROP TYPE completion_state;
    SQL
  end
end

