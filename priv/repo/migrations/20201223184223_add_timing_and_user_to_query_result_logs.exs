defmodule EpiLocator.Repo.Migrations.AddTimingAndUserToQueryResultLogs do
  use Ecto.Migration

  def change do
    alter table(:query_result_logs) do
      add(:msec_elapsed, :integer)
      add(:user, :string)
    end
  end
end
