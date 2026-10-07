from fastapi import FastAPI
from pydantic import BaseModel

from ai.moteur import analyser_question


app = FastAPI(
    title="SantéAdo - Moteur IA",
    description="API du moteur d'assistance IA de SantéAdo",
    version="1.0.0",
)


class QuestionRequest(BaseModel):
    message: str


@app.get("/")
def accueil():
    return {
        "message": "Moteur IA SantéAdo opérationnel",
        "statut": "ok",
    }


@app.post("/ia/question")
def poser_question(request: QuestionRequest):
    return analyser_question(request.message)