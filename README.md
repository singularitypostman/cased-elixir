# cased-elixir

A Cased client for Elixir applications in your organization to control and monitor the access of information within your organization.

## Overview

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Publishing events to Cased](#publishing-events-to-cased)
  - [Retrieving events from a Cased Policy](#retrieving-events-from-a-cased-policy)
  - [Retrieving events from a Cased Policy containing variables](#retrieving-events-from-a-cased-policy-containing-variables)
  - [Retrieving events from multiple Cased Policies](#retrieving-events-from-multiple-cased-policies)
  - [Exporting events](#exporting-events)
  - [Masking & filtering sensitive information](#masking-and-filtering-sensitive-information)
  - [Disable publishing events](#disable-publishing-events)
  - [Context](#context)
  - [Testing](#testing)
- [Customizing cased-elixir](#customizing-cased-elixir)

## Installation

The package can be installed by adding `cased` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cased, "~> 0.1.0"}
  ]
end
```

## Configuration

`cased-elixir` follows Elixir's [Library Guidelines](https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-application-configuration), avoiding the use of a global `:cased` application configuration in favor of more flexible, ad hoc configuration at runtime (using your own application configuration, environment variables, etc).

### For Publisher

Add a worker specification for `Cased.Publisher.HTTP` to your application's supervisor.

The publisher accepts the following options:

- `:key` — Your [Cased publish key](https://docs.cased.com/apis#authentication-and-api-keys) (**required**).
- `:url` — The URL used to publish audit trail events via HTTP POST (**optional**;
  defaults to `https://publish.cased.com`).
- `:silence` — Whether audit trail events will be discarded, rather than sent; useful for
  non-production usage (**optional**; defaults to `false`).
- `:timeout` — The request timeout, in milliseconds (**optional**; defaults to `15_000`)

You can source your configuration values from your application configuration,
runtime environment variables, or hard-code them directly; the following is just
an example:

```elixir
children = [
  # Other workers...
  {
    Cased.Publisher.HTTP,
    key: System.get_env("CASED_PUBLISH_KEY") || Application.fetch_env!(:your_app, :cased_publish_key),
    silence: Mix.env() != :prod
  }
]

# Other config...
Supervisor.start_link(children, opts)
```

In the event you provide an invalid configuration, a `Cased.ConfigurationError` will be raised with details.

### For Client

To access Cased API routes and functionality other than publishing, configure a
client using `Cased.Client.create/1`:

The function accepts the following options:

- `:key` — Your `default` [Cased policy key](https://docs.cased.com/apis#authentication-and-api-keys). This is
  shorthand for providing `:keys`, as explained below, with a value for
  `:default`:
- `:keys` - Your [Cased policy keys](https://docs.cased.com/apis#authentication-and-api-keys), by audit trail ([example below](#keys-example))
- `:url` — The API URL (**optional**; defaults to `https://api.cased.com`).
- `:timeout` — The request timeout, in milliseconds (**optional**; defaults to
  `15_000`)

These configuration values can be provided a number of ways, as shown in the
examples below.

#### Examples

Create a client with the policy key for your `default` audit trail:

```elixir
{:ok, client} = Cased.Client.create(key: "policy_live_...")
```

<a name="keys-example"></a>
Create a client key with policy keys for specific audit trails:

```elixir
{:ok, client} = Cased.Client.create(keys: [default: "policy_live_...", users: "policy_live_..."])
```

Clients can be configured using runtime environment variables, your application
configuration, hardcoded values, or any combination you choose:

```elixir
# Just using runtime environment variable:
{:ok, client} = Cased.Client.create(key: System.fetch_env!("CASED_POLICY_KEY"))

# Just using application configuration:
{:ok, client} = Cased.Client.create(key: Application.fetch_env!(:your_app, :cased_policy_key))

# Either/or
{:ok, client} = Cased.Client.create!(key: System.get_env("CASED_POLICY_KEY") || Application.fetch_env!(:your_app, :cased_policy_key))
```

In the event your client is misconfigured, you'll get a `Cased.ConfigurationError` exception struct instead:

```elixir
# Not providing required options:
{:error, %Cased.ConfigurationError{}} = Cased.Client.create()
```

You can also use `Cased.Client.create!/1` if you know you're passing the correct configuration options (otherwise it raises a `Cased.ConfigurationError` exception):

```elixir
client = Cased.Client.create!(key: "policy_live_...")
```

To simplify using clients across your application, consider writing a centralized function to handle constructing them:

```elixir
defmodule YourApp do

  # Rest of contents ...

  def cased_client do
    default_policy_key = System.get_env("CASED_POLICY_KEY") || Application.fetch_env!(:your_app, :cased_policy_key)
    Cased.Client.create!(key: default_policy_key, silence: Mix.env() != :prod)
  end
end
```

For reuse, consider caching your client structs in GenServer state, ETS, or another Elixir caching mechanism.

## Usage

### Publishing events to Cased

#### Manually

Provided you've [configured](#for-publisher) the Cased publisher, use `Cased.publish/1`:

```elixir
%{
  action: "credit_card.charge",
  amount: 2000,
  currency: "usd",
  source: "tok_amex",
  description: "My First Test Charge (created for API docs)",
  credit_card_id: "card_1dQpXqQwXxsQs9sohN9HrzRAV6y"
}
|> Cased.publish()

```

### Retrieving events from a Cased Policy

TK

### Retrieving events from a Cased Policy containing variables

TK

### Retrieving events from multiple Cased Policies

TK

### Exporting events

TK

### Masking & filtering sensitive information

TK

### Console Usage

TK

### Disable publishing events

TK

### Context

TK

### Testing

TK

## Customizing cased-elixir

TK

## Contributing

1. Fork it ( https://github.com/cased/cased-elixir/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
