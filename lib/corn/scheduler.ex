defmodule Corn.Scheduler do
  use GenServer
  require Logger

  @name __MODULE__
  @default_delay 0

  def start_link(_opts) do
    GenServer.start_link(@name, %{}, name: @name)
  end

  @impl true
  def init(_state) do
    state = schedule_tasks()
    {:ok, state}
  end

  @impl true
  def handle_info({:schedule, task_name}, state) do
    cfg = config() |> Map.new
    case task_name in Map.keys(cfg) do
      true ->
        {mod, fun, period, _delay} = unpack_opts(cfg[task_name])
        {_name, task} = schedule({task_name, mod, fun, period, 0})
        state = Map.replace!(state, task_name, task)
        {:noreply, state}
      _ -> {:noreply, state}
    end
  end

  defp schedule_tasks do
    config()
    |> Enum.map(fn {name, opts} ->
      {mod, fun, period, delay} = unpack_opts(opts)
      {name, mod, fun, period, delay}
    end)
    |> Enum.map(&schedule/1)
    |> Map.new
  end

  defp unpack_opts(opts) do
    mod =     Keyword.get(opts, :module)
    fun =     Keyword.get(opts, :function)
    period =  Keyword.get(opts, :period)
    delay =   Keyword.get(opts, :delay, @default_delay)
    {mod, fun, period, delay}
  end

  defp config do
    Application.get_all_env(:corn)
    |> Enum.filter(fn {root_key, _opts} ->
      String.starts_with?(to_string(root_key), "Elixir.Corn.")
    end)
  end

  @spec schedule({atom(), atom(), non_neg_integer(), non_neg_integer()}) :: %{String.t => {:ok, pid() | nil}}
  defp schedule({name, mod, fun, period, 0 = _delay}) do
    {:ok, pid} = Task.Supervisor.start_child(Corn.TaskSupervisor, fn ->
      Logger.info("[#{name}] Starting #{mod}.#{fun}")
      start = now_ms()
      apply(mod, fun, [])
      elapsed = (now_ms() - start) / 1000
      Logger.info("[#{name}] Done in #{Float.round(elapsed, 3)} seconds")
    end)
    Process.send_after(self(), {:schedule, name}, period * 1000)
    {name, pid}
  end

  defp schedule({name, _mod, _fun, _period, delay}) do
    Process.send_after(self(), {:schedule, name}, delay * 1000)
    {name, nil}
  end

  defp now_ms do
    :erlang.monotonic_time
    |> System.convert_time_unit(:native, :millisecond)
  end
end
