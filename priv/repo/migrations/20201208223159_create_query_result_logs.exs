defmodule EpiLocator.Repo.Migrations.CreateQueryResultLogs do
  use Ecto.Migration

  def change do
    create table(:query_result_logs) do
      add :domain, :string
      add :case_type, :string
      add :success, :boolean, default: false, null: false
      add :results, :integer
      add :timestamp, :utc_datetime
    end
  end
end
