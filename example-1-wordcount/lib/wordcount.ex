defmodule WordCount do

  @top_n_words 10

  @switches [file: :string]
  def main(argv) do
    {options, _, _} = OptionParser.parse(argv, strict: @switches)

    options
    |> run
    |> to_exit_status
  end

  def run(options) do
    with {:ok, _} <- WordCount.State.init,
      {:ok, file_stream} <- get_file(options),
      :ok <- do_counting(file_stream),
      {:ok, result} <- summarize(),
    do: IO.puts(result)
  end

  def to_exit_status({:error, reason}) do
    IO.puts(reason)
    1
  end
  def to_exit_status(_), do: 0

  def get_file(options) do
    case Keyword.has_key?(options, :file) do
      false -> {:error, "Provide file to process with --file"}
      true ->
        path = options[:file]
        case File.exists?(path) do
          false -> {:error, "File provided could not be found: #{path}"}
          true -> {:ok, File.stream!(path, [], :line)}
        end
    end
  end

  def do_counting(stream) do
    task = Task.async(fn -> WorkCount.Counter.count(stream) end)
    Task.await(task, :infinity)
    :ok
  end

  def summarize do
    sorted_words = WordCount.State.sort_desc
    |> Enum.take(@top_n_words)
    |> Enum.with_index(1)
    |> Enum.map(fn {{word, count}, index} ->
        "#{index}: #{word} - #{count}"
      end)
    |> Enum.join("\n")

    {:ok, "\nCount complete, Top #{@top_n_words} words by usage:\n" <> sorted_words}
  end
end
