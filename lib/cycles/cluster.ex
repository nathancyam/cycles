defmodule Cycles.Cluster do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def members do
    GenServer.call(__MODULE__, :members)
  end

  @impl GenServer
  def init(_) do
    :net_kernel.monitor_nodes(true)
    nodes = [Node.self() | Node.list()]
    Logger.info("Cluster: #{Enum.join(nodes, ", ")}")
    {:ok, nodes}
  end

  @impl GenServer
  def handle_info({:nodeup, node}, state) do
    Logger.info(message: "Node up", node: inspect(node))
    {:noreply, [node | state]}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info(message: "Node down", node: inspect(node))
    {:noreply, List.delete(state, node)}
  end

  @impl GenServer
  def handle_call(:members, _from, state) do
    {:reply, state, state}
  end
end
