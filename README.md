# corn

A simple, naive, but understood scheduler.

## Installation

The package can be installed by adding `corn` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:corn, "~> 0.1.0"}
  ]
end
```

## Usage

`corn` is used in a declarative fashion.
In you relevant application config:

```elixir
config :corn, MyApp.Task,
  module: MyApp.Task,
  function: :do_work,
  period: 86400, # daily
  delay: 180

config :corn, MyApp.OtherTask,
  module: MyApp.OtherTask,
  function: :do_work,
  period: 3600, # hourly
  delay: 180
```
