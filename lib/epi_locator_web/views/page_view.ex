defmodule EpiLocatorWeb.PageView do
  use EpiLocatorWeb, :view

  import EpiLocatorWeb.Plugs.RequireValidSignature,
    only: [commcare_signature_key: 0, commcare_signature_secret: 0]
end
