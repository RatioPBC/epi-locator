defmodule EpiLocator.TestTemplates do
  @moduledoc false
  use Phoenix.Template, root: "test/fixtures/templates"

  def render(template, assigns) do
    render_template(template, assigns)
  end
end
