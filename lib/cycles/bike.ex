defmodule Cycles.Bike do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, name: opts[:name])
  end
end
