defmodule EpiLocator.Repo.Migrations.RemoveObanTables do
  use Ecto.Migration

  def up do
    drop_if_exists table("oban_beats")
    drop_if_exists table("oban_jobs")
  end

  def down do
    raise Ecto.MigrationError, message: "manually add Oban back"
  end
end
