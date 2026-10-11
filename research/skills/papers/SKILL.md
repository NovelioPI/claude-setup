---
name: papers
description: Find papers and write paper notes. Search by topic, citations, or similarity, keep notes/reading-list.md, and write notes/papers/<id>.md. Use when the user asks for related work, new papers, what to read next, or to read, summarize, or compare a paper.
---

# Search and read papers

## Search

| Need | Source |
|---|---|
| Search by topic | Semantic Scholar paper search |
| Papers that cite a paper | Semantic Scholar citations |
| Papers similar to a paper | Semantic Scholar recommendations |
| Newest preprints | arXiv API, sorted by submission date |
| Trending and daily papers | HF MCP `hf_fs`: `hf://papers/trending`, `hf://papers/daily/latest` |

Call Semantic Scholar with `curl`. Send `x-api-key: $S2_API_KEY` when the
variable is set:

    curl -s -H "x-api-key: $S2_API_KEY" \
      "https://api.semanticscholar.org/graph/v1/paper/search?query=<q>&limit=20&fields=title,year,externalIds,citationCount,abstract"
    curl -s "https://api.semanticscholar.org/graph/v1/paper/arXiv:<id>/citations?fields=title,year,externalIds&limit=50"
    curl -s "https://api.semanticscholar.org/recommendations/v1/papers/forpaper/arXiv:<id>?limit=20&fields=title,year,externalIds"

Call arXiv with `curl`:

    curl -s "https://export.arxiv.org/api/query?search_query=all:<q>&sortBy=submittedDate&max_results=20"

On a 429 from Semantic Scholar, say so once, and use arXiv and HF instead.
If `S2_API_KEY` is unset, tell the user that a free key fixes the 429.

Rank by relevance to the user's question, not by citation count alone.
Add each result to the reading list.

## Reading list

Keep `notes/reading-list.md`. Add a row only for a paper you checked exists.

    | ID | Title | Year | Why read it | Status |
    |---|---|---|---|---|

ID is the arXiv ID, or the Semantic Scholar paper ID when there is none.
Status is `to read`, `noted`, or `skipped`. Never add a row twice.
Create the file when it is missing.

## Note

Read from the first source that works:

1. HF MCP `hf_fs`: `cat hf://papers/<arxiv-id>/paper.md`.
2. arXiv HTML: `https://arxiv.org/html/<arxiv-id>`.
3. The PDF, with the Read tool, a page range at a time.

Write `notes/papers/<id>.md`:

    # <title> (<year>)
    <arXiv or DOI link>

    | Field | Content |
    |---|---|
    | Problem | <one sentence> |
    | Method | <two sentences at most> |
    | Datasets and benchmarks | <names> |
    | Code | <link, or "none found"> |

    ## Results
    | Claim | Number | Where |
    |---|---|---|

    ## Limits
    - <stated by the authors, then ones you see; label which is which>

    ## Ideas for us
    - <how this could feed the user's experiments>

Every number needs a Where cell: a section, table, or figure.
Risk: if a number has no source, then it may be invented and spreads into ideas.

Write "not stated" for a field the paper does not cover. Never guess.
Then set the paper's row in the reading list to `noted`, adding it if missing.
