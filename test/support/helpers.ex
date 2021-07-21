defmodule EpiLocator.Test.Helpers do
  @moduledoc false

  def read_xml_and_turn_into_map(filename) do
    filename
    |> File.read!()
    |> XmlToMap.naive_map()
  end

  def read_tr_xml_and_turn_into_map(filename) do
    filename
    |> read_xml_and_turn_into_map()
    |> Map.get("{http://clear.thomsonreuters.com/api/search/2.0}PersonResultsPage")
  end
end
