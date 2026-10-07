# Backend SantéAdo (chatbot)

## 1. Lancement en local (pour tester avant de déployer)

```bash
cd backend
python -m venv venv
source venv/bin/activate          # Windows : venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env              # puis remplis .env si tu as une clé API
uvicorn main:app --reload
```

Teste ensuite : http://localhost:8000/health -- tu dois voir
`{"status": "ok", "ia_configuree": false, "firestore_configure": false}`
si tu n'as encore rien configuré. C'est normal, la banque locale répond
quand même.

## 2. Fonctionnement sans budget API (par défaut)

Ne renseigne pas `ANTHROPIC_API_KEY` : le chatbot répond via la banque
locale (`reponse_banque_locale` dans `main.py`), sans coût. C'est un
mode de fonctionnement assumé, pas un pis-aller caché -- ton cahier des
charges prévoit explicitement ce scénario.

## 3. Activer l'IA réelle (si un budget/crédit API est disponible)

1. Crée une clé sur https://console.anthropic.com
2. Renseigne `ANTHROPIC_API_KEY=sk-ant-...` dans `.env` (local) ou dans
   les variables d'environnement de ton hébergeur (prod)
3. Redémarre le serveur -- aucune autre modification nécessaire

## 4. Connecter Firestore (journalisation des échanges + alertes)

1. Console Firebase > Paramètres du projet > Comptes de service >
   Générer une nouvelle clé privée -- télécharge le fichier JSON
2. Place-le dans `backend/` (déjà ignoré par git, voir `.gitignore`)
3. Renseigne `FIREBASE_CREDENTIALS_PATH=./ma-cle.json` dans `.env`

Sans cette étape, le chat fonctionne mais rien n'est enregistré dans
Firestore (pas d'historique consultable par l'admin, pas d'alertes).

## 5. Déploiement (obligatoire pour que l'app mobile puisse l'appeler)

L'app Flutter ne peut pas contacter `localhost` -- il faut héberger ce
backend quelque part d'accessible sur internet. Options gratuites
adaptées à un MVP étudiant :

### Render (recommandé, le plus simple)
1. Crée un compte sur https://render.com
2. "New +" > "Web Service" > connecte ton dépôt GitHub (dossier `backend/`)
3. Build command : `pip install -r requirements.txt`
4. Start command : `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Ajoute tes variables d'environnement (`ANTHROPIC_API_KEY`,
   `FIREBASE_CREDENTIALS_PATH` si utilisé -- ou colle le contenu du JSON
   dans une variable et adapte le code pour le lire depuis une variable
   plutôt qu'un fichier, plus simple sur Render)
6. Une fois déployé, tu obtiens une URL du type
   `https://santeado-backend.onrender.com`

### Railway (alternative, aussi simple)
Même principe, https://railway.app, détection automatique de FastAPI.

⚠️ Sur le plan gratuit de Render, le service "s'endort" après 15 min
d'inactivité et met quelques secondes à redémarrer au premier appel --
attends-toi à un léger délai lors du premier message envoyé en
démonstration après une pause.

## 6. Brancher l'URL dans Flutter

Une fois déployé, remplace l'URL placeholder dans
`lib/services/chat_service.dart` (côté Flutter) par ta vraie URL
Render/Railway. On fait cet écran ensuite.
