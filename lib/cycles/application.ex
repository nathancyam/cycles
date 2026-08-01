defmodule Cycles.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ExHashRing.Ring

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Cycles.Worker.start_link(arg)
      # {Cycles.Worker, arg}
      {Ring, [name: Cycles.HashRing]},
      Cycles.Cluster,
      {Cycles.NodeListener, [name: Cycles.NodeListener]},
      {Registry, [keys: :unique, name: Cycles.Registry]},
      {DynamicSupervisor, [name: Cycles.DynamicSupervisor, strategy: :one_for_one]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cycles.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
