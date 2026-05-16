// Création de la collection "fiche_film_complet" qui permet d'exécuter la première requête

db.movies_clean.createIndex({ id: 1 });
db.workers_clean.createIndex({ id: 1 });

db.movies_actors_clean.createIndex({ movie_id: 1 });
db.movies_actors_clean.createIndex({ actor_id: 1 });

db.movies_awards_clean.createIndex({ movie_id: 1 });
db.movies_awards_clean.createIndex({ award_id: 1 });

db.movies_genres_clean.createIndex({ movie_id: 1 });
db.movies_genres_clean.createIndex({ genre_id: 1 });

db.awards_clean.createIndex({ id: 1 });
db.genres_clean.createIndex({ id: 1 });

db.movies_clean.aggregate([
  {
    $lookup: {
      from: "workers_clean",
      localField: "director_id",
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
    $lookup: {
      from: "movies_actors_clean",
      localField: "id",
      foreignField: "movie_id",
      as: "actor_links"
    }
  },

  {
    $lookup: {
      from: "workers_clean",
      localField: "actor_links.actor_id",
      foreignField: "id",
      as: "actor_infos"
    }
  },

  {
    $lookup: {
      from: "movies_awards_clean",
      localField: "id",
      foreignField: "movie_id",
      as: "award_links"
    }
  },

  {
    $lookup: {
      from: "awards_clean",
      localField: "award_links.award_id",
      foreignField: "id",
      as: "award_infos"
    }
  },

  {
    $lookup: {
      from: "movies_genres_clean",
      localField: "id",
      foreignField: "movie_id",
      as: "genre_links"
    }
  },

  {
    $lookup: {
      from: "genres_clean",
      localField: "genre_links.genre_id",
      foreignField: "id",
      as: "genre_infos"
    }
  },

  {
    $project: {
      _id: 0,
      id: 1,
      title: 1,
      year: 1,

      director: {
        id: "$director.id",
        name: "$director.name"
      },

      actors: {
        $map: {
          input: "$actor_links",
          as: "link",
          in: {
            actor_id: "$$link.actor_id",
            role: "$$link.role",

            actor_name: {
              $let: {
                vars: {
                  actor: {
                    $arrayElemAt: [
                      {
                        $filter: {
                          input: "$actor_infos",
                          as: "a",
                          cond: {
                            $eq: ["$$a.id", "$$link.actor_id"]
                          }
                        }
                      },
                      0
                    ]
                  }
                },
                in: "$$actor.name"
              }
            }
          }
        }
      },

      awards: {
        $map: {
          input: "$award_links",
          as: "link",
          in: {
            award_id: "$$link.award_id",
            year: "$$link.year",

            award_name: {
              $let: {
                vars: {
                  award: {
                    $arrayElemAt: [
                      {
                        $filter: {
                          input: "$award_infos",
                          as: "aw",
                          cond: {
                            $eq: ["$$aw.id", "$$link.award_id"]
                          }
                        }
                      },
                      0
                    ]
                  }
                },
                in: "$$award.name"
              }
            },

            award_category: {
              $let: {
                vars: {
                  award: {
                    $arrayElemAt: [
                      {
                        $filter: {
                          input: "$award_infos",
                          as: "aw",
                          cond: {
                            $eq: ["$$aw.id", "$$link.award_id"]
                          }
                        }
                      },
                      0
                    ]
                  }
                },
                in: "$$award.category"
              }
            }
          }
        }
      },

      genres: {
        $map: {
          input: "$genre_infos",
          as: "g",
          in: "$$g.name"
        }
      }
    }
  },

  {
    $out: "fiche_film_complet"
  }
])





// Requête 1 : Récupérer toutes les informations d'un film : titre, nom directeur, nom acteur, rôle, award, catégorie award
// Ce code renvoie TOUTES les fiches de films ayant le titre indiqué
// Test ci-dessous avec "Card" comme titre, renvoie 86 films 
//Temps d'exécution : 376 ms

use movies_project

db.fiche_film_complet.createIndex({ title: 1 });

const start = Date.now();

const films = db.fiche_film_complet.aggregate([
  {
    $match: {
      title: "Card"
    }
  },
  {
    $project: {
      _id: 0,
      title: "$title",
      year: "$year",
      nom_directeur: "$director.name",

      acteurs: {
        $map: {
          input: "$actors",
          as: "actor",
          in: {
            nom_acteur: "$$actor.actor_name",
            role_acteur: "$$actor.role"
          }
        }
      },

      awards: {
        $map: {
          input: "$awards",
          as: "award",
          in: {
            nom_award: "$$award.award_name",
            categorie_award: "$$award.award_category"
          }
        }
      },

      genres: "$genres"
    }
  }
]).toArray();

const end = Date.now();

print("Nombre de films trouvés : " + films.length);
print("Temps d'exécution : " + (end - start) + " ms");

printjson(films);






