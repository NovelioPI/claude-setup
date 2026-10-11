# Call an LLM in research code

## Model

Pin the exact, dated model ID, such as `gpt-4o-2024-08-06`. Never use an alias.
Risk: if the ID is an alias, then the model changes under a finished benchmark.

For a Hugging Face model, pin `revision=<commit hash>`, not a branch name.

## Client

Pass the client in as a parameter. Do not build a global client.
Read the API key from the environment. Never print or log it.

## Requests

Build every request in one function, so the full request is visible in one place.
Use temperature 0 for evaluation. When sampling is the point, log the sample
count and the temperature.
Set `seed` when the API accepts it, and log it.

## Cache

Cache each response on disk in `.cache/llm/`, and add that folder to `.gitignore`.
Key it on the SHA-256 of the exact request plus the sample index.
Reason: a change to the prompt, a variable, a parameter, or the model changes the
request, so it misses the cache by itself.

Give the run a `--no-cache` switch. Log the cache hit count as an MLflow metric.
Risk: if every request hits the cache, then a "new" run repeats old answers.

## Retries

Retry with exponential backoff only on rate limits, timeouts, and server errors.
Do not retry a 4xx error other than 429.
Reason: a bad request fails the same way again and still costs money.

## Logging

Log these with each MLflow run:

| Value | How |
|---|---|
| Model ID | param `model` |
| Temperature, seed, max tokens | params |
| Prompt name and hash | see `~/.claude/research/guides/prompts.md` |
| Input and output tokens | metrics, summed over the run |
| Cost | metric, from the token counts |
