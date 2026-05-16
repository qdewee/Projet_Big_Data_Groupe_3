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



//On crée ensuite la collection actor_movies, celle-ci reprend tous les ID de films dans lesquels un acteur a joué. Cela permet de réduire de façon significative le lookup devant être fait durant la requête.


db.movies_actors_clean.createIndex({ actor_id: 1 });
db.movies_actors_clean.createIndex({ movie_id: 1 });

const start = Date.now();

db.movies_actors_clean.aggregate([

  {
    $group: {
      _id: "$actor_id",

      movie_ids: {
        $addToSet: "$movie_id"
      }
    }
  },

  {
    $project: {
      _id: 0,

      actor_id: "$_id",

      movie_ids: 1,

      number_of_movies: {
        $size: "$movie_ids"
      }
    }
  },

  {
    $sort: {
      number_of_movies: -1
    }
  },

  {
    $out: "actor_movies"
  }

]);

db.actor_movies.createIndex({ actor_id: 1 });

const end = Date.now();

print("Collection actor_movies créée avec succès.");
print("Temps d'exécution : " + (end - start) + " ms");



//Requête dynamique qui permet de retourner pour un utilisateur indiqué, tous les films non-vus, incluant au moins un acteur ayant joué dans un film déjà vu par l'utilisateur :

use movies_project

const userName = "Michelle Anderson";

const start = Date.now();

const user = db.users_clean.findOne({ name: userName });

if (!user) {
  print("Aucun utilisateur trouvé avec ce nom : " + userName);
} else {

  const userActors = db.user_seen_actors.findOne({
    user_id: user.id
  });

  if (!userActors) {
    print("Aucun historique trouvé pour l'utilisateur : " + userName);
  } else {

    const result = db.actor_movies.aggregate([

      {
        $match: {
          actor_id: { $in: userActors.actor_ids }
        }
      },

      {
        $unwind: "$movie_ids"
      },

      {
        $match: {
          movie_ids: { $nin: userActors.watched_movie_ids }
        }
      },

      {
        $group: {
          _id: "$movie_ids",
          matching_actor_ids: {
            $addToSet: "$actor_id"
          }
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
          user_name: user.name,
          user_id: user.id,
          movie_id: "$_id",
          title: "$movie.title",
          year: "$movie.year",
          director: "$director.name",
          matching_actor_count: {
            $size: "$matching_actor_ids"
          }
        }
      },

      {
        $sort: {
          matching_actor_count: -1,
          year: -1,
          title: 1
        }
      }

    ]).toArray();

    const end = Date.now();

    print("Utilisateur : " + user.name);
    print("Nombre de films recommandés : " + result.length);
    print("Temps d'exécution : " + (end - start) + " ms");

    printjson(result);
  }
}
















