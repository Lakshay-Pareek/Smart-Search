from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..schemas.search import SearchRequest, SearchResponse, SuggestionResponse
from ..db.database import get_db
from ..db.models import History
from ..services.search_engine import SearchEngine, get_search_engine

router = APIRouter()


@router.post("", response_model=SearchResponse)
async def search_documents(
    payload: SearchRequest,
    engine: SearchEngine = Depends(get_search_engine),
    db: Session = Depends(get_db),
) -> SearchResponse:
  """
  Core search entrypoint.

  This will eventually use:
  - inverted index for fast term lookup
  - TF-IDF + PageRank style scoring
  - KMP / suffix array / edit distance for advanced matching
  """
  results = engine.search(
      query=payload.query,
      top_k=payload.top_k,
      filters=payload.filters or {},
  )
  # Persist history so History tab stays updated across restarts.
  db.add(History(query=payload.query, results=len(results)))
  db.commit()
  return SearchResponse(
      query=payload.query,
      total=len(results),
      results=results,
  )


@router.get("/suggest", response_model=SuggestionResponse)
async def suggest(
    q: str = Query("", min_length=1),
    limit: int = 10,
    engine: SearchEngine = Depends(get_search_engine),
) -> SuggestionResponse:
  """Autocomplete suggestions backed by a Trie structure."""
  suggestions = engine.suggest(prefix=q, limit=limit)
  return SuggestionResponse(prefix=q, suggestions=suggestions)

