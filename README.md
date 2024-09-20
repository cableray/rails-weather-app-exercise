# Weather app with caching

Toy app to fufill the following requirements:

- Must be done in Ruby on Rails
- Accept an address as input
- Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- Display the requested forecast details to the user
- Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.
 
Assumptions:
- This project is open to interpretation
- Functionality is a priority over form
- If you get stuck, complete as much as you can

## Deploy notes

Set the API_KEY env var from https://www.visualcrossing.com/weather-api in order to make api calls. tests mock this out.

## Testing

standard `bundle install` and then `bundle exec rspec spec/ui_spec.rb`

## Design notes

- Skipped handling some edge cases, like api failures.
- I have all the json date, so adding more of the forecast is just iterating over it and rendering (probably a decent use for a partial)
- I wanted to use an adapter pattern to wrap the api call. I noticed that not all weather api providers accept addresses, and so using a secondary api to get lat/long first would be needed for some api providers. This would be an interesting design challenge, if the goal was to make the api providers "swappable" or "polymorphic". It might also be a good use for patterns like a simplified middleware pattern or a workflow/pipelining pattern.
- This was strict TDD, and I did this top-down with integration tests driving things, and then refactoring. Some lower unit tests might fill the gaps, but it wasn't really needed yet (but it felt close to that point)
- Rails cache is a good place to start for caching, but it is limited, especially because it doesn't have an "else" clause, so "if cached or not" logic is hard to reason about. The api is okay, but might be better wrapped to fit the usecase here. Or maybe, `#fetch` is wrong for the usecase, and just check if it's cached and write manually.
- even the minimal rails skeleton still feels pretty big. I like to add stuff in, instead of pull stuff out. 
- httpx makes a good case for being the best ruby http client, even if it's newer. But, that meant no VCR support... not that webmock really needs it. Oh, I probably should make a PR to webmock to fix the `curl -is` parsing for `http/2` responses
- a bit of mutation testing would help drive better coverage, but line coverage is pretty good
- I like to inline stuff. Ruby seems to consider that idiomatic, last I checked. `#tap` is neat, but maybe too clever.
- Definately could use a couple more extract-to-method refactorings, and maybe pulling out a concern?