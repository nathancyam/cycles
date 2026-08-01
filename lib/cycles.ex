defmodule Cycles do
  @moduledoc """
  Documentation for `Cycles`.
  """

  defguardp is_strategy(strategy) when strategy in [:ex_hash_ring, :hrw]

  @doc """
  Start a process with the given identifier. The process will be started on the
  node determined via the hash ring. This process is then registered locally
  via the Registry to make it identifable.
  """
  def start_process(process_id, strategy)
      when is_binary(process_id) and
             is_strategy(strategy) do
    case fetch_node(process_id, strategy) do
      {:ok, node} ->
        :rpc.call(node, DynamicSupervisor, :start_child, [
          Cycles.DynamicSupervisor,
          {Cycles.Bike, [name: via_name(process_id)]}
        ])

      {:error, _reason} = err ->
        err
    end
  end

  def find_process(process_id, strategy)
      when is_binary(process_id) and is_strategy(strategy) do
    current_node = node()

    case fetch_node(process_id, strategy) do
      {:ok, ^current_node} ->
        Registry.lookup(Cycles.Registry, process_id)

      {:ok, other_node} ->
        :rpc.call(other_node, Registry, :lookup, [Cycles.Registry, process_id])

      {:error, _reason} = err ->
        err
    end
  end

  defp fetch_node(process_id, :ex_hash_ring) do
    ExHashRing.Ring.find_node(Cycles.HashRing, process_id)
  end

  defp fetch_node(process_id, :hrw) do
    nodes = Cycles.Cluster.members()
    owner = HRW.owner(process_id, nodes)
    {:ok, owner}
  end

  defp via_name(process_identifier), do: {:via, Registry, {Cycles.Registry, process_identifier}}
end
