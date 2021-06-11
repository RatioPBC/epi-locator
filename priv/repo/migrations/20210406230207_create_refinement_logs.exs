defmodule EpiLocator.Repo.Migrations.CreateRefinementLogs do
  use Ecto.Migration

  def change do
    create table(:refinement_logs) do
      add :first_name, :boolean, default: false, null: false
      add :last_name, :boolean, default: false, null: false
      add :city, :boolean, default: false, null: false
      add :state, :boolean, default: false, null: false
      add :phone, :boolean, default: false, null: false
      add :dob, :boolean, default: false, null: false
      add :user, :string
      add :total_results, :integer
      add :refined_results, :integer
      add :timestamp, :utc_datetime
      add :domain, :string
      add :case_type, :string
    end
  end
end
