from __future__ import annotations

from collections import defaultdict
import heapq
import math
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple


@dataclass
class IndexedDocument:
  id: str
  title: str
  content: str
  document_type: Optional[str] = None
  source: Optional[str] = None
  updated_at: Optional[str] = None


class TrieNode:
  __slots__ = ("children", "is_end")

  def __init__(self) -> None:
    self.children: Dict[str, "TrieNode"] = {}
    self.is_end: bool = False


class Trie:
  def __init__(self) -> None:
    self.root = TrieNode()

  def insert(self, word: str) -> None:
    node = self.root
    for ch in word.lower():
      if ch not in node.children:
        node.children[ch] = TrieNode()
      node = node.children[ch]
    node.is_end = True

  def _collect(self, node: TrieNode, prefix: str, acc: List[str]) -> None:
    if node.is_end:
      acc.append(prefix)
    for ch, child in node.children.items():
      self._collect(child, prefix + ch, acc)

  def suggest(self, prefix: str, limit: int = 10) -> List[str]:
    node = self.root
    for ch in prefix.lower():
      if ch not in node.children:
        return []
      node = node.children[ch]
    results: List[str] = []
    self._collect(node, prefix.lower(), results)
    return results[:limit]


class SearchEngine:
  """
  In‑memory search engine with:
  - inverted index
  - simple TF‑IDF scoring
  - Trie‑based autocomplete
  - min‑heap top‑K selection

  This is a backend core that we can later back with PostgreSQL‑loaded documents.
  """

  def __init__(self, documents: Optional[List[IndexedDocument]] = None) -> None:
    self.documents: Dict[str, IndexedDocument] = {}
    self.inverted_index: Dict[str, Dict[str, int]] = defaultdict(dict)
    self.doc_freq: Dict[str, int] = defaultdict(int)
    self.trie = Trie()
    if documents:
      for doc in documents:
        self.add_document(doc)

  @staticmethod
  def _tokenize(text: str) -> List[str]:
    tokens = []
    current = []
    for ch in text.lower():
      if ch.isalnum():
        current.append(ch)
      else:
        if current:
          tokens.append("".join(current))
          current = []
    if current:
      tokens.append("".join(current))
    return tokens

  def add_document(self, doc: IndexedDocument) -> None:
    self.documents[doc.id] = doc
    seen_terms = set()
    tokens = self._tokenize(doc.title + " " + doc.content)
    for term in tokens:
      posting = self.inverted_index[term]
      posting[doc.id] = posting.get(doc.id, 0) + 1
      if term not in seen_terms:
        self.doc_freq[term] += 1
        seen_terms.add(term)
      # insert words into trie for autocomplete
      self.trie.insert(term)

  def search(
      self, query: str, top_k: int = 10, filters: Optional[Dict[str, str]] = None
  ) -> List[Dict[str, object]]:
    if not query.strip():
      return []
    filters = filters or {}
    query_terms = self._tokenize(query)
    if not query_terms:
      return []

    # compute scores: simple TF-IDF like scoring
    scores: Dict[str, float] = defaultdict(float)
    N = max(len(self.documents), 1)

    for term in query_terms:
      posting = self.inverted_index.get(term)
      if not posting:
        continue
      df = self.doc_freq.get(term, 1)
      idf = math.log(N / df)
      for doc_id, tf in posting.items():
        scores[doc_id] += tf * idf

    # apply filters and get top‑K using min‑heap
    heap: List[Tuple[float, str]] = []
    for doc_id, score in scores.items():
      doc = self.documents.get(doc_id)
      if not doc:
        continue
      # simple filter support, e.g. document_type, source
      if "document_type" in filters and doc.document_type != filters["document_type"]:
        continue
      if "source" in filters and doc.source != filters["source"]:
        continue

      heapq.heappush(heap, (score, doc_id))
      if len(heap) > top_k:
        heapq.heappop(heap)

    top_results = sorted(heap, key=lambda x: x[0], reverse=True)
    results: List[Dict[str, object]] = []
    for score, doc_id in top_results:
      doc = self.documents[doc_id]
      # create a small snippet from start of content
      snippet = doc.content[:220] + "..." if len(doc.content) > 220 else doc.content
      results.append(
          {
              "id": doc.id,
              "title": doc.title,
              "snippet": snippet,
              "score": float(score),
              "document_type": doc.document_type,
              "source": doc.source,
              "updated_at": doc.updated_at,
          }
      )
    return results

  def suggest(self, prefix: str, limit: int = 10) -> List[str]:
    if not prefix:
      return []
    return self.trie.suggest(prefix, limit=limit)


_search_engine: Optional[SearchEngine] = None


def get_search_engine() -> SearchEngine:
  global _search_engine
  if _search_engine is None:
    # Initialized empty; seeded from DB at FastAPI startup.
    _search_engine = SearchEngine([])
  return _search_engine

