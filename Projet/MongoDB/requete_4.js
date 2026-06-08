// Ce code permet d'exécuter la requête suivante : introduire le nom d'un acteur et retourne tous les films dans lequel il a joué ainsi que tous les awards gagnés

//On commence par créer la collection Historique_acteur

db.historique_acteur.drop()

db.workers_clean.aggregate([
  {
    $lookup: {
      from: "movies_actors_clean",
      localField: "id",
      foreignField: "actor_id",
      as: "roles"
    }
  },
  {
    $match: {
      roles: { $ne: [] }
    }
  },
  {
    $lookup: {
      from: "movies_clean",
      localField: "roles.movie_id",
      foreignField: "id",
      as: "movies"
    }
  },
  {
    $lookup: {
      from: "movies_awards_clean",
      localField: "roles.movie_id",
      foreignField: "movie_id",
      as: "movie_awards"
    }
  },
  {
    $lookup: {
      from: "awards_clean",
      localField: "movie_awards.award_id",
      foreignField: "id",
      as: "awards"
    }
  },
  {
    $project: {
      _id: 0,
      actor_id: "$id",
      actor_name: "$name",
      films: {
        $map: {
          input: "$movies",
          as: "m",
          in: {
            title: "$$m.title",
            year: "$$m.year"
          }
        }
      },
      awards: {
        $map: {
          input: "$awards",
          as: "a",
          in: {
            name: "$$a.name",
            category: "$$a.category"
          }
        }
      }
    }
  },
  {
    $out: "historique_acteur"
  }
])


//On crée 2 index : Le premier indexe classique permet de retourner pour le nom exacte directement la recherche. 
//Le deuxième, un indexe type texte permet de chercher comme un moteur de recherche et retourne tous les résultats correspondants

db.historique_acteur.createIndex({ actor_name: 1 })
db.historique_acteur.createIndex({ actor_name: "text" })

//Le code ci-dessous permet d'exécuter la requete avec les 2 indexes, et retourne les statistiques de résolution


const acteur = "Jared Lewis"

// ======================================================
// 1. RECHERCHE AVEC INDEX CLASSIQUE actor_name: 1
// ======================================================

print("\n==============================")
print("RECHERCHE AVEC INDEX CLASSIQUE")
print("==============================")

const requeteClassique = {
  actor_name: acteur
}

// Résultats retournés
const resultatsClassiques = db.historique_acteur
  .find(requeteClassique, { _id: 0 })
  .toArray()

print("\nRésultats obtenus :")
printjson(resultatsClassiques)

// Statistiques d'exécution
const statsClassiques = db.historique_acteur
  .find(requeteClassique)
  .explain("executionStats")

print("\nStatistiques :")
print("Temps d'exécution :", statsClassiques.executionStats.executionTimeMillis, "ms")
print("Documents examinés :", statsClassiques.executionStats.totalDocsExamined)
print("Index keys examinées :", statsClassiques.executionStats.totalKeysExamined)
print("Documents retournés :", statsClassiques.executionStats.nReturned)


// ======================================================
// 2. RECHERCHE AVEC INDEX TEXTE actor_name: "text"
// ======================================================

print("\n==============================")
print("RECHERCHE AVEC INDEX TEXTE")
print("==============================")

const requeteTexte = {
  $text: {
    $search: acteur
  }
}

// Résultats retournés
const resultatsTexte = db.historique_acteur
  .find(requeteTexte, { _id: 0 })
  .toArray()

print("\nRésultats obtenus :")
printjson(resultatsTexte)

// Statistiques d'exécution
const statsTexte = db.historique_acteur
  .find(requeteTexte)
  .explain("executionStats")

print("\nStatistiques :")
print("Temps d'exécution :", statsTexte.executionStats.executionTimeMillis, "ms")
print("Documents examinés :", statsTexte.executionStats.totalDocsExamined)
print("Index keys examinées :", statsTexte.executionStats.totalKeysExamined)
print("Documents retournés :", statsTexte.executionStats.nReturned)


// ======================================================
// 3. COMPARAISON SYNTHÉTIQUE
// ======================================================

print("\n==============================")
print("COMPARAISON SYNTHÉTIQUE")
print("==============================")

print("Acteur recherché :", acteur)

print("\nIndex classique actor_name: 1")
print("- Temps :", statsClassiques.executionStats.executionTimeMillis, "ms")
print("- Documents examinés :", statsClassiques.executionStats.totalDocsExamined)
print("- Index keys examinées :", statsClassiques.executionStats.totalKeysExamined)
print("- Résultats retournés :", statsClassiques.executionStats.nReturned)

print("\nIndex texte actor_name: 'text'")
print("- Temps :", statsTexte.executionStats.executionTimeMillis, "ms")
print("- Documents examinés :", statsTexte.executionStats.totalDocsExamined)
print("- Index keys examinées :", statsTexte.executionStats.totalKeysExamined)
print("- Résultats retournés :", statsTexte.executionStats.nReturned)
















