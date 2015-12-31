# Play along

*v1.0 or greater is fine*

```bash
$ mix -v
Mix 1.0.5

$ elixir -v
Elixir 1.0.5
```

—

## Getting Comfortable with the Elixir Development Environment

^ When learning a new language, most people focus on syntax and design patterns.

^ Once have cursory understanding of syntax, I like to understand the language environment and tooling.

^ Hope to show you the lay of the land when it comes to Elixir app dev so you know how to even get to the point to start on your first play app. Meant to be at pace you can follow on your laptop…

—

# What is a language environment?

* Build tool
* Testing framework
* Interactive shell
* Dependency resolution
* Configuration management

^ Might seem scattered, but all are things you need in place before you can do anything of consequence with the language.

^ First thing is how to create an app, what dir structure is it expecting etc… First tool: Mix

—

# Mix

* Project bootstrapper (like `script/rails g`)
* Build utility/script runner (like Rake)
* Dependency manager (like Bundler)

^ Mix is the core command line tool of Elixir, responsible for many things

^ Let's see how it creates projects for us

—

# Create new project

```bash
$ mix help
mix                   # Run the default task (current: mix run)
mix app.start         # Start all registered apps
…

$ mix new triangle
$ cd triangle
$ ls
README.md config    lib       mix.exs   test
```

^ Look at dir structure: config, lib and test dirs

^ mix.exs: Main entrypoint for app - define apps, dependencies, metadata

^ Compile w/ `mix compile`, look at `_build` for build artifacts. Erlang VM code. Elixir compiles to Erlang bytecode. Important b/c have Erlang app.

^ mix test

^ Other frameworks plug into mix to provide project generators: E.g., `mix phoenix.new` for Phoenix apps

^ Test provide convenient way to get some code executing, so start there

—

# Test

```elixir
# test/triangle_test.exs
test "area" do
  assert Triangle.area(3, 5) == 3 * 5 / 2
end
```

```bash
$ mix test
```

```elixir
# lib/triangle.ex
def area(base, height), do: base * height / 2
```

^ Edit `triangle_test.exs`. `exs` extension means script, no build artifacts

^ `area` function uses single-line body. Common when simple body definitions

^ Can also run individual tests: `mix test test/triangle_test.exs:4`

^ Tests are good to quickly run code, but sometimes need more ad-hoc environment to play in…

—

# IEx

* Interactive elixir, REPL
* Loads Elixir environment w/ shell access
* Dynamically reload code

^ IEx is the easiest way to start playing with Elixir and has lot of niceties to help you navigate and get around

—

# IEx playground

```bash
$ iex
> c "lib/triangle.ex"
> Triangle.area 2, 3
3.0
> r Triangle
> h Enum.<tab>
```

```bash
$ iex -S mix
> Triangle.area 2, 3
```

^ Start IEx w/ `iex`. Do `a = 1`. Do `h` to show helpers

^ `h Enum.<tab>` to show tab-completion. `ls` to see FS. Very friendly, navigable environment.

^ `c "lib/triangle.ex"` to compile and load sample app. `Triangle.area 2, 3`. Edit triangle.ex, and `r Triangle` to get updated def.

^ Ctrl-C, Ctrl-C to quit

^ Shortcut to load all app dependencies, `iex -S mix`

—

# Debugging

* Print messages to stdout
* Attach interactive shell to running process (IEx.pry)

—

# Print to stdout

```elixir
def area(base, height) do
	IO.puts "base: #{base}, height: #{height}"
	base * height / 2
end
```

^ Add puts statement to `area` and run test

^ IO.puts, IO.inspect

^ Familiar string interpolation available

—

# Attached shell

Add `IEx.pry` statement

```elixir
require IEx

def area(base, height), do: IEx.pry && base * height / 2
```

Get access to local scope:

```bash
$ iex -S mix
> Triangle.area 2, 3
pry(1)> base
2
pry(2)> respawn
```

^ IEx.pry attaches to current IEx session, lets you peak/manipulate local scope

^ `respawn` gets out of IEx.pry, but any changed state is not kept

—

# Dependencies

* Package manager is called Hex (https://hex.pm)
* Dependency resolution handled by Mix
* Project dependencies defined in `mix.exs`

^ Three components to dependency management. Publically accessible repo of packages, way to fetch them, and place to define them

—

# Add dependency

```elixir
# triangle.ex
require Metrix
def area(base, height) do
  Metrix.measure "triangle.area", fn -> base * height / 2 end
end
```

```elixir
# mix.exs
def application do
  [applications: [:logger, :metrix]]
end

defp deps do
  [
    {:metrix, "~> 0.2.0"}
  ]
end
```

```bash
$ mix deps.get
```

^ Add simple metrics library to Triangle as example

^ Edit `Triangle`, add metrix to `application` and `deps` of `mix.exs`. In `applications` if it's a sub-app with own supervisor tree. If just a lib, only in `deps`. Depends on implementation.

^ Notice: it's all code, no YAML

^ Run `mix deps.get`, look in `deps` dir to see dependencies locally vendored

^ mix test to see Metrix output

—

# Configuration

* `config/` contains configurations
* `Config` sets up app values

^ Every lang has different way, or no consistent way at all, to define environment-specific configuration. Elixir has first class `config` support.

^ Look in `config/config.exs`

—

# Using config values

```elixir
# config/config.ex
config :triangle, :default_length, 4
```

```elixir
# triangle.ex
def equilateral(length), do: {length, length, length}
def equilateral do
  Application.get_env(:triangle, :default_length))
  |> equilateral
end
```

```elixir
# triangle_test.exs
test "default equilateral side length of 4" do
  assert Triangle.equilateral == {4, 4, 4}
end
```

^ Add config value in `config/config.exs`, first arg must match app atom

^ Add `equilateral` def to Triangle, test

^ `Application.get_env/2` to get values

—

# Environments

* `Mix.env` available at runtime
* Environment specific configs in `config/`

^ Quite often need way to toggle between configs depending on env

^ Uses file-based configurations

—

# Environment configuration

```bash
$ touch config/dev.exs config/test.exs
```

```elixir
# config/dev.exs
use Mix.Config
config :triangle, :default_length, 3
```

```elixir
# config/test.exs
use Mix.Config
config :triangle, :default_length, 2
```

^ Add `config/` files for test and dev, add separate length values. Run `mix test` to see errors

^ Load iex to see dev value: Application.get_env(:triangle, :default_length))

^ Show `Mix.env` value

^ Actual environment (not app vars) accessible via `System.get_env/1`

^ I find config/Application.get_env/System.env to be a bit confusing due to the overloading of "environment".

<!--

# Your own tasks

Create poor man's CLI, tasks can help
In triangle.ex

```elixir
defmodule Mix.Tasks.Triangle.Area do
  use Mix.Task

  def run([base, height]) do
    {base, _} = Float.parse(base)
    {height, _} = Float.parse(height)
    Mix.bash.info to_string(Triangle.area({base, height}))
  end
end
```

```bash
$ mix triangle.area 4 9
```
-->
