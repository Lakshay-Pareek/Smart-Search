from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy import desc
from sqlalchemy.orm import Session

from ..db.database import get_db
from ..db.models import History

router = APIRouter()


@router.get("")
async def list_history(db: Session = Depends(get_db)) -> List[dict]:
  items = db.query(History).order_by(desc(History.timestamp)).limit(200).all()
  return [
      {
          "id": str(h.id),
          "query": h.query,
          "timestamp": h.timestamp.isoformat().replace("+00:00", "Z"),
          "results": h.results,
      }
      for h in items
  ]

