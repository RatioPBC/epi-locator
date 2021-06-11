defmodule EpiLocator.SearchChooser do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:source, Ecto.Enum, values: [:index_case, :parent_guardian])
  end

  def changeset(form, params \\ %{}) do
    form
    |> cast(params, [:source])
  end
end
