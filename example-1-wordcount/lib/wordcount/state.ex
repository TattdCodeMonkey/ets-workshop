defmodule WordCount.State do
  @default_data []

  defp name, do: __MODULE__

  def init do
    case :ets.info(name) do
      :undefined ->
        name = :ets.new(name, [:set, :named_table, :public])
        true = :ets.insert(name, @default_data)
        {:ok, name}
      _ -> {:ok, name}
    end
  end

  def get, do: :ets.match_object(name, {:"$1", :"$2"})

  def increment_word(word) do
    :ets.update_counter(name, word, 1, {word, 0})
  end

  def clear_words do
    true = :ets.delete_all_objects(name)
    :ok
  end

  def sort_desc do
    current = get
    Enum.sort(current, fn {_, v1}, {_, v2} -> v1 > v2 end)
  end
end
