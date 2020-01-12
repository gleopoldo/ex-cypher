# ExCypher

![](https://github.com/gleopoldo/ex-cypher/workflows/Test/badge.svg)
![](https://github.com/gleopoldo/ex-cypher/workflows/Code%20Quality/badge.svg)

Want a DSL to interact with Neo4j? Tired of concatenating stuff in your queries?

Use Ex-Cypher!

This project aims to solve that problems by providing a clean DSL to interact
with Neo4j through Cypher query language.

## Installation

Add this to your `mix.exs`:

```elixir
def deps do
  [
    {:ex_cypher, "~> 0.1.0"}
  ]
end
```

## Usage

Let's try to build some simple queries with `ex-cypher`:

#### Basic Usage

Add to your module this first line:

```
import ExCypher, only: [:cypher]
```

Then you can play around with our `cypher` macro. It'll attempt to convert
all you calls to cypher compliant code:

```elixir
cypher do
  match node(:p, [:Person], %{first_name: "bob", last_name: "thaves"})
  return :p
end
```

Returns:

```
MATCH (p:Person {"first_name":"bob", "last_name":"thaves"})
RETURN p
```

I strongly recommend you to read the project docs [here](https://hexdocs.pm/ex_cypher).

### Contributing

All help and feedback is welcome. If you want to contribute with PR, 
I've created a simple development environment with docker (so that one doesn't
need to have elixir installed locally) - and you can run it's CLI through
`./script/ex-cypher`.

### License

This project is distributed under the MIT license.
