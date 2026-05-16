//Code complet pour l'exécution de la requête 2 : "Trouver les films avec une note moyenne supérieure à 4.5"


//Première étape : création collection films_bien_notes
//Temps d'exécution : 729235 ms

use movies_project

db.ratings_clean.createIndex({ movie_id: 1 });
db.movies_clean.createIndex({ id: 1 });

const start = Date.now();

db.ratings_clean.aggregate([
  {
    $group: {
      _id: "$movie_id",
      note_moyenne: { $avg: "$rating" },
      nombre_notes: { $sum: 1 }
    }
  },
  {
    $match: {
      note_moyenne: { $gt: 4.5 }
    }
  },
  {
    $lookup: {
      from: "movies_clean",
      localField: "_id",
      foreignField: "id",
      as: "movie"
    }
  },
  {
    $unwind: "$movie"
  },
  {
    $project: {
      _id: 0,
      movie_id: "$_id",
      title: "$movie.title",
      year: "$movie.year",
      director_id: "$movie.director_id",
      note_moyenne: { $round: ["$note_moyenne", 2] },
      nombre_notes: 1
    }
  },
  {
    $sort: {
      note_moyenne: -1,
      nombre_notes: -1
    }
  },
  {
    $out: "films_bien_notes"
  }
]);

const end = Date.now();

print("Collection films_bien_notes créée avec succès.");
print("Temps d'exécution : " + (end - start) + " ms");

db.films_bien_notes.createIndex({ note_moyenne: -1 });
db.films_bien_notes.createIndex({ title: 1 });



//Code pour la lancer la requête qui retourne tous les films avec une note > 4.5 et leurs informations correspondantes : titre, année, ID et directeur

use movies_project

db.films_bien_notes.createIndex({ movie_id: 1 });
db.movies_clean.createIndex({ id: 1 });
db.workers_clean.createIndex({ id: 1 });

const start = Date.now();

const result = db.films_bien_notes.aggregate([

  {
    $lookup: {
      from: "movies_clean",
      localField: "movie_id",
      foreignField: "id",
      as: "movie"
    }
  },

  {
    $unwind: "$movie"
  },

  {
    $lookup: {
      from: "workers_clean",
      localField: "movie.director_id",
      foreignField: "id",
      as: "director"
    }
  },

  {
    $unwind: {
      path: "$director",
      preserveNullAndEmptyArrays: true
    }
  },

  {
    $project: {
      _id: 0,
      titre: "$movie.title",
      annee: "$movie.year",
      directeur: "$director.name",
      note_moyenne: 1,
      nombre_notes: 1
    }
  },

  {
    $sort: {
      note_moyenne: -1,
      nombre_notes: -1
    }
  }

]).toArray();

const end = Date.now();

print("Nombre de films trouvés : " + result.length);
print("Temps d'exécution : " + (end - start) + " ms");

printjson(result);




