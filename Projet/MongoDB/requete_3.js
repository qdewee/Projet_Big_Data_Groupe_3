//La requête 3 consiste à : "Trouver des films non regardés par un utilisateur ayant des acteurs qui ont joué dans des films qu'il a déjà regardés"

//On commence par créer une première collection user_seen_actors qui reprend pour chaque user tous les acteurs ayant joué dasn des films vu par l'utilisateur
//Temps d'exécution : 178635 ms
use movies_project

db.watch_history_clean.createIndex({ user_id: 1 });
db.watch_history_clean.createIndex({ movie_id: 1 });
db.movies_actors_clean.createIndex({ movie_id: 1 });
db.movies_actors_clean.createIndex({ actor_id: 1 });

const start = Date.now();

db.watch_history_clean.aggregate([

  {
    $lookup: {
      from: "movies_actors_clean",
      localField: "movie_id",
      foreignField: "movie_id",
      as: "actors_in_seen_movie"
    }
  },

  {
    $unwind: "$actors_in_seen_movie"
  },

  {
    $group: {
      _id: "$user_id",
      actor_ids: {
        $addToSet: "$actors_in_seen_movie.actor_id"
      },
      watched_movie_ids: {
        $addToSet: "$movie_id"
      }
    }
  },

  {
    $project: {
      _id: 0,
      user_id: "$_id",
      actor_ids: 1,
      watched_movie_ids: 1,
      number_of_seen_actors: {
        $size: "$actor_ids"
      },
      number_of_seen_movies: {
        $size: "$watched_movie_ids"
      }
    }
  },

  {
    $out: "user_seen_actors"
  }

]);

db.user_seen_actors.createIndex({ user_id: 1 });

const end = Date.now();

print("Collection user_seen_actors créée avec succès.");
print("Temps d'exécution : " + (end - start) + " ms");

//On teste le résultat avec le code ci-dessous : 

db.user_seen_actors.find(
  {},
  {
    _id: 0,
    user_id: 1,
    number_of_seen_movies: 1,
    number_of_seen_actors: 1
  }
).limit(10)



//On crée ensuite la collection recommendations_by_actor qui reprend pour chaque utilisateur les films non regardés par l'utilisateur ayant au moins un acteur dans la collection précédente, avec titre + année + driecteur et pour chaque utilisateur son id et son nom correspondant


















