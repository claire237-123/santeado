import json
from pathlib import Path
import requests

from .regles import REGLES


# ============================================================
# CONFIGURATION OLLAMA
# ============================================================

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
MODELE_OLLAMA = "qwen3:0.6b"


# ============================================================
# DOSSIER DES CONNAISSANCES
# ============================================================

DOSSIER_CONNAISSANCES = (
    Path(__file__).parent / "connaissances"
)


# ============================================================
# CHARGEMENT DES CONNAISSANCES
# ============================================================

def charger_connaissances() -> list:
    """
    Charge toutes les connaissances présentes
    dans les fichiers JSON de SantéAdo.
    """

    connaissances = []

    if not DOSSIER_CONNAISSANCES.exists():
        return connaissances

    for fichier in DOSSIER_CONNAISSANCES.glob("*.json"):

        try:

            with open(
                fichier,
                "r",
                encoding="utf-8"
            ) as f:

                donnees = json.load(f)

            # ------------------------------------------------
            # Nouveau format :
            # un fichier peut contenir plusieurs connaissances
            # ------------------------------------------------

            if "connaissances" in donnees:

                for connaissance in donnees["connaissances"]:

                    connaissance_complete = {
                        "categorie": donnees.get(
                            "categorie",
                            "inconnue"
                        ),
                        "niveau": donnees.get(
                            "niveau",
                            "information_generale"
                        ),
                        "type": donnees.get(
                            "type",
                            "information"
                        ),
                        **connaissance
                    }

                    connaissances.append(
                        connaissance_complete
                    )

            # ------------------------------------------------
            # Ancien format :
            # un fichier = une connaissance
            # ------------------------------------------------

            else:

                connaissances.append(donnees)

        except (
            json.JSONDecodeError,
            OSError
        ) as e:

            print(
                f"Erreur lors du chargement de "
                f"{fichier.name} : {e}"
            )

    return connaissances


# ============================================================
# RECHERCHE D'UNE CONNAISSANCE
# ============================================================

def rechercher_connaissance(message: str):
    """
    Recherche la connaissance SantéAdo la plus pertinente.

    Priorité :
    1. Expressions prioritaires exactes
    2. Expressions normales
    3. Aucun résultat -> Ollama
    """

    texte = message.lower().strip()

    connaissances = charger_connaissances()

    # ---------------------------------------------------------
    # 1. PRIORITÉ ABSOLUE AUX MOTS-CLÉS PRIORITAIRES
    # ---------------------------------------------------------

    meilleure_connaissance = None
    meilleur_score = 0

    for connaissance in connaissances:

        score = 0

        for mot in connaissance.get("mots_cles_prioritaires", []):

            mot = mot.lower().strip()

            if not mot:
                continue

            if mot in texte:

                nombre_mots = len(mot.split())

                # Les expressions longues sont très spécifiques.
                score += 100 + (nombre_mots * 20)

        if score > meilleur_score:
            meilleur_score = score
            meilleure_connaissance = connaissance

    # Si une intention précise a été trouvée,
    # on la retourne immédiatement.
    if meilleure_connaissance is not None:
        return meilleure_connaissance

    # ---------------------------------------------------------
    # 2. RECHERCHE DANS LES MOTS-CLÉS NORMAUX
    # ---------------------------------------------------------

    meilleure_connaissance = None
    meilleur_score = 0

    for connaissance in connaissances:

        score = 0

        for mot_cle in connaissance.get("mots_cles", []):

            mot_cle = mot_cle.lower().strip()

            if not mot_cle:
                continue

            if mot_cle in texte:

                nombre_mots = len(mot_cle.split())

                score += 10 * nombre_mots

        if score > meilleur_score:
            meilleur_score = score
            meilleure_connaissance = connaissance

    if meilleure_connaissance is None:
        return None

    return meilleure_connaissance
# ============================================================
# DÉTECTION DE LA CATÉGORIE
# ============================================================

def detecter_categorie(message: str) -> str:
    """
    Détermine la catégorie générale de la question
    à partir des règles SantéAdo.
    """

    texte = message.lower().strip()

    for categorie, mots_cles in REGLES.items():

        for mot in mots_cles:

            if mot.lower() in texte:

                return categorie

    return "inconnue"


# ============================================================
# INTERROGER OLLAMA
# ============================================================

def interroger_ollama(
    message: str,
    contexte: str = ""
) -> str:
    """
    Interroge Qwen3 via Ollama lorsqu'aucune
    connaissance précise n'a été trouvée.
    """

    prompt = f"""
Tu es l'assistant IA de la plateforme SantéAdo.

SantéAdo est une plateforme de sensibilisation
des adolescentes à la santé sexuelle et reproductive.

RÈGLES :

- Réponds toujours en français.
- Utilise un langage simple et respectueux.
- Donne uniquement des informations générales.
- Ne pose jamais de diagnostic médical.
- Ne prescris aucun traitement personnalisé.
- Ne prétends pas remplacer un professionnel de santé.
- Si une situation nécessite une consultation,
  recommande de consulter un professionnel.
- Ne fabrique pas de faits médicaux.

CONTEXTE SANTÉADO :

{contexte}

QUESTION :

{message}

Réponds de manière claire et concise.
"""

    try:

        response = requests.post(
            OLLAMA_URL,
            json={
                "model": MODELE_OLLAMA,
                "prompt": prompt,
                "stream": False
            },
            timeout=120
        )

        response.raise_for_status()

        data = response.json()

        return data.get(
            "response",
            "Je n'ai pas pu générer une réponse."
        ).strip()

    except requests.exceptions.RequestException as e:

        print(
            f"Erreur Ollama : {e}"
        )

        return (
            "Je rencontre actuellement un problème "
            "technique. Tu peux réessayer dans quelques instants."
        )


# ============================================================
# ANALYSE PRINCIPALE
# ============================================================

def analyser_question(message: str) -> dict:
    """
    Fonction principale du moteur IA SantéAdo.
    """

    # --------------------------------------------------------
    # 1. Détection de la catégorie générale
    # --------------------------------------------------------

    categorie = detecter_categorie(message)

    # --------------------------------------------------------
    # 2. Recherche d'une connaissance précise
    # --------------------------------------------------------

    connaissance = rechercher_connaissance(message)

    # --------------------------------------------------------
    # 3. Connaissance trouvée
    # --------------------------------------------------------

    if connaissance:

        return {
            "categorie": connaissance.get(
                "categorie",
                categorie
            ),

            "connaissance": connaissance.get(
                "id",
                None
            ),

            "titre": connaissance.get(
                "titre",
                ""
            ),

            "reponse": connaissance.get(
                "reponse",
                ""
            ),

            "conseil": connaissance.get(
                "conseil",
                ""
            ),

            "type": connaissance.get(
                "type",
                "information"
            ),

            "source": "connaissances_santeado",

            "modele": None
        }

    # --------------------------------------------------------
    # 4. Aucune connaissance précise trouvée
    # --------------------------------------------------------

    reponse = interroger_ollama(
        message=message,
        contexte=""
    )

    return {
        "categorie": categorie,

        "connaissance": None,

        "titre": "",

        "reponse": reponse,

        "conseil": "",

        "type": "information",

        "source": "ollama_local",

        "modele": MODELE_OLLAMA
    }