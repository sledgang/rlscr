![image](http://imgur.com/ebyJ0pD.jpg)

# **rlscr**

Crystal REST API wrapper for [RocketLeagueStats](https://rocketleaguestats.com/)

- [API Documentation](http://documentation.rocketleaguestats.com/)
- [Request an API key](https://developers.rocketleaguestats.com/)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  rls:
    github: z64/rlscr
```

## Usage

```crystal
require "rls"

client = RLS::Client.new("YOUR_API_KEY")
client.player("76561197968760517") #=> RLS::Player
```

## Contributors

- [z64](https://github.com/z64) Zac Nowicki - creator, maintainer
