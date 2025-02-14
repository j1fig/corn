defmodule Corn.Scheduler do
  use GenServer
  require Logger

  alias Corn.Cfg

  @name __MODULE__

  def start_link(_opts) do
    GenServer.start_link(@name, %{}, name: @name)
  end

  @impl true
  def init(_state) do
    state = schedule_tasks()
    {:ok, state}
  end

  defp schedule_tasks do
    Cfg.get()
    |> Enum.map(fn {name, opts} ->
      {mod, fun, period, delay} = Cfg.unpack(opts)
      {name, mod, fun, period, delay}
    end)
    |> Enum.map(&schedule/1)
    |> Map.new
  end

  @impl true
  def handle_info({:schedule, task_name}, state) do
    cfg = Cfg.get() |> Map.new
    maybe_run_task(task_name, state, cfg, task_name in Map.keys(cfg))
  end

  defp maybe_run_task(_task_name, state, _cfg, false = _task_in_cfg), do: {:noreply, state}
  defp maybe_run_task(task_name, state, cfg, _task_in_cfg) do
    {mod, fun, period, _delay} = Cfg.unpack(cfg[task_name])
    {_name, task} = schedule({task_name, mod, fun, period, 0})
    state = Map.replace!(state, task_name, task)
    {:noreply, state}
  end

  @spec schedule({atom(), atom(), atom(), non_neg_integer()}) :: %{String.t => {:ok, pid() | nil}}
  def schedule({name, mod, fun, period, 0 = _delay}) do
    {:ok, pid} = run(name, mod, fun)
    Process.send_after(self(), {:schedule, name}, period * 1000)
    {name, pid}
  end

  def schedule({name, _mod, _fun, _period, delay}) do
    Process.send_after(self(), {:schedule, name}, delay * 1000)
    {name, nil}
  end

  @spec run(atom(), atom(), atom()) :: {:ok, pid()}
  def run(name, mod, fun) do
    Task.Supervisor.start_child(Corn.TaskSupervisor, fn ->
      Logger.info("[#{name}] Starting #{mod}.#{fun}")
      start = now_ms()
      apply(mod, fun, [])
      elapsed = (now_ms() - start) / 1000
      Logger.info("[#{name}] Done in #{Float.round(elapsed, 3)} seconds")
    end)
  end

  defp now_ms do
    :erlang.monotonic_time
    |> System.convert_time_unit(:native, :millisecond)
  end
end
