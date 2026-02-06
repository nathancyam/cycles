defmodule Cycles.NodeListener do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(_) do
    :net_kernel.monitor_nodes(true)
    current_node = node()

    ExHashRing.Ring.add_node(Cycles.HashRing, current_node)
    {:ok, current_node}
  end

  def handle_info({:nodeup, node}, state) do
    if node != state do
      Logger.info(message: "Node up", node: inspect(node))
      ExHashRing.Ring.add_node(Cycles.HashRing, node)
    end

    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    if node != state do
      Logger.info(message: "Node down", node: inspect(node))
      ExHashRing.Ring.remove_node(Cycles.HashRing, node)
    end

    {:noreply, state}
  end
end
