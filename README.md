# Cycles

A small experiment to see whether I can get a Erlang cluster that utilises a consistent hash ring to place data on a fixed node.

## Usage

Start up a cluster of 3 nodes:

```bash
$ iex --sname node1 -S mix
$ iex --sname node2 -S mix
$ iex --sname node3 -S mix
```

Then on any of the nodes, manually connect them like so:

```elixir
# On node1
iex> Node.connect!(:'node2@yourhostname')
iex> Node.connect!(:'node3@yourhostname')
```

On the other nodes, you should see a log message that the hash ring has been updated with the nodes:

```
22:36:10.584 [info] [message: "Node up", node: ":\"node01@yourhostname\""]
```

Now you can using the hash ring to find which node to use for a given key across any Erlang node:

```elixir
# On node1
iex> ExHashRing.Ring.find_node(Cycles.HashRing, "a")
{:ok, :"node01@yourhostname"}
```

```elixir
# On node2
iex> ExHashRing.Ring.find_node(Cycles.HashRing, "a")
{:ok, :"node01@yourhostname"}
```
