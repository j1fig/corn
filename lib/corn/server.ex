defmodule Corn.Server do
  use Supervisor

  @name __MODULE__

  def start_link(args) do
    Supervisor.start_link(@name, args, name: @name)
  end

  @impl true
  def init(_args) do
    children = [
      {Task.Supervisor, name: Corn.TaskSupervisor},
      {Corn.Scheduler,  name: Corn.Scheduler},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
