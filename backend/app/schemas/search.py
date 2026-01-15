from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class SearchRequest(BaseModel):
  query: str = Field(..., min_length=1)
  top_k: int = Field(10, ge=1, le=100)
  filters: Optional[Dict[str, Any]] = None


class SearchResult(BaseModel):
  id: str
  title: str
  snippet: str
  score: float
  document_type: Optional[str] = None
  source: Optional[str] = None
  updated_at: Optional[str] = None


class SearchResponse(BaseModel):
  query: str
  total: int
  results: List[SearchResult]


class SuggestionResponse(BaseModel):
  prefix: str
  suggestions: List[str]

