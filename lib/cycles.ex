defmodule Cycles do
  @moduledoc """
  Documentation for `Cycles`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cycles.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Start a process with the given identifier. The process will be started on the
  node determined via the hash ring. This process is then registered locally
  via the Registry to make it identifable.
  """
  def start_process(process_identifier) when is_binary(process_identifier) do
    case find_node(process_identifier) do
      {:ok, node} ->
        :rpc.call(node, DynamicSupervisor, :start_child, [
          Cycles.DynamicSupervisor,
          {Cycles.Bike, [name: via_name(process_identifier)]}
        ])

      {:error, _reason} = err ->
        err
    end
  end

  def find_process(process_identifier) when is_binary(process_identifier) do
    current_node = node()

    case find_node(process_identifier) do
      {:ok, ^current_node} ->
        Registry.lookup(Cycles.Registry, process_identifier)

      {:ok, other_node} ->
        :rpc.call(other_node, Registry, :lookup, [Cycles.Registry, process_identifier])

      {:error, _reason} = err ->
        err
    end
  end

  def find_node(process_identifier) do
    ExHashRing.Ring.find_node(Cycles.HashRing, process_identifier)
  end

  defp via_name(process_identifier) do
    {:via, Registry, {Cycles.Registry, process_identifier}}
  end
end
