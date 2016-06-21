defmodule WorkCount.Counter do
  @max_current_line_tasks 20

  def count(stream) do
    Enum.reduce(stream, {0,[]},&task_counting/2)
  end

  def task_counting(line, {outstanding_tasks, tasks})
    when outstanding_tasks >= @max_current_line_tasks do

    wait_for_tasks(tasks)

    task_counting(line, {0, []})
  end
  def task_counting(line, {outstanding_tasks, tasks}) do
    task_pid = Task.async(fn -> count_words(line) end)
    {outstanding_tasks + 1, [task_pid | tasks]}
  end

  def wait_for_tasks(tasks) do
    tasks
    |> Enum.reverse
    |> Enum.map(&(Task.await(&1)))

    :ok
  end

  def finish({_, tasks}), do: wait_for_tasks(tasks)

  def count_words(line) do
    line
    |> String.strip
    |> String.downcase
    |> String.split
    |> Enum.each(fn word -> WordCount.State.increment_word(word) end)
  end
end
