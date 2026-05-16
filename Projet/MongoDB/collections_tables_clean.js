use movies_project

// =======================
// 1. WORKERS → workers_clean
// =======================

db.workers.aggregate([
  {
    $match: {
      id: { $exists: true, $ne: null },
      name: { $exists: true, $type: "string", $nin: [null, ""] }
    }
  },
  {
    $project: {
      _id: 0,
      id: 1,
      name: { $trim: { input: "$name" } }
    }
  },
  {
    $match: {
      name: { $ne: "" }
    }
  },
  {
    $out: "workers_clean"
  }
])


// =======================
// 2. USERS → users_clean
// =======================

db.users.aggregate([
  {
    $match: {
      id: { $exists: true, $ne: null },
      name: { $exists: true, $type: "string", $nin: [null, ""] }
    }
  },
  {
    $project: {
      _id: 0,
      id: 1,
      name: { $trim: { input: "$name" } }
    }
  },
  {
    $match: {
      name: { $ne: "" }
    }
  },
  {
    $out: "users_clean"
  }
])


// =======================
// 3. MOVIES → movies_clean
// =======================

db.movies.aggregate([
  {
    $match: {
      id: { $exists: true, $ne: null },
      title: { $exists: true, $type: "string", $nin: [null, ""] },
      year: {
        $exists: true,
        $type: "number",
        $gte: 1888,
        $lte: 2030
      }
    }
  },
  {
    $project: {
      _id: 0,
      id: 1,
      title: { $trim: { input: "$title" } },
      year: 1,
      director_id: 1,
      rating: {
        $cond: [
          {
            $and: [
              { $ne: ["$rating", null] },
              { $gte: ["$rating", 0] },
              { $lte: ["$rating", 5] }
            ]
          },
          "$rating",
          "$$REMOVE"
        ]
      },
      metadata: {
        $cond: [
          { $eq: [{ $type: "$metadata" }, "object"] },
          "$metadata",
          "$$REMOVE"
        ]
      }
    }
  },
  {
    $match: {
      title: { $ne: "" }
    }
  },
  {
    $out: "movies_clean"
  }
])


// =======================
// 4. AWARDS → awards_clean
// =======================

db.awards.aggregate([
  {
    $match: {
      id: { $exists: true, $ne: null },
      name: { $exists: true, $type: "string", $nin: [null, ""] },
      category: { $exists: true, $type: "string", $nin: [null, ""] }
    }
  },
  {
    $project: {
      _id: 0,
      id: 1,
      name: { $trim: { input: "$name" } },
      category: { $trim: { input: "$category" } }
    }
  },
  {
    $match: {
      name: { $ne: "" },
      category: { $ne: "" }
    }
  },
  {
    $out: "awards_clean"
  }
])


// =======================
// 5. GENRES → genres_clean
// =======================

db.genres.aggregate([
  {
    $match: {
      id: { $exists: true, $ne: null },
      name: { $exists: true, $type: "string", $nin: [null, ""] }
    }
  },
  {
    $project: {
      _id: 0,
      id: 1,
      name: { $trim: { input: "$name" } }
    }
  },
  {
    $match: {
      name: { $ne: "" }
    }
  },
  {
    $out: "genres_clean"
  }
])


// =======================
// 6. RATINGS → ratings_clean
// =======================

db.ratings.aggregate([
  {
    $match: {
      user_id: { $exists: true, $ne: null },
      movie_id: { $exists: true, $ne: null },
      rating: {
        $exists: true,
        $type: "number",
        $gte: 0,
        $lte: 5
      }
    }
  },
  {
    $project: {
      _id: 0,
      user_id: 1,
      movie_id: 1,
      rating: 1
    }
  },
  {
    $out: "ratings_clean"
  }
])

// =======================
// MOVIES_ACTORS → movies_actors_clean
// =======================

db.movies_actors.aggregate([
  {
    $match: {
      movie_id: { $exists: true, $ne: null },
      actor_id: { $exists: true, $ne: null }
    }
  },
  {
    $project: {
      _id: 0,
      movie_id: 1,
      actor_id: 1,
      role: {
        $cond: [
          { $eq: [{ $type: "$role" }, "string"] },
          { $trim: { input: "$role" } },
          "$$REMOVE"
        ]
      }
    }
  },
  {
    $out: "movies_actors_clean"
  }
])

// =======================
// MOVIES_AWARDS → movies_awards_clean
// =======================

db.movies_awards.aggregate([
  {
    $match: {
      movie_id: { $exists: true, $ne: null },
      award_id: { $exists: true, $ne: null }
    }
  },
  {
    $project: {
      _id: 0,
      movie_id: 1,
      award_id: 1,
      year: 1
    }
  },
  {
    $out: "movies_awards_clean"
  }
])


// =======================
// MOVIES_GENRES → movies_genres_clean
// =======================

db.movies_genres.aggregate([
  {
    $match: {
      movie_id: { $exists: true, $ne: null },
      genre_id: { $exists: true, $ne: null }
    }
  },
  {
    $project: {
      _id: 0,
      movie_id: 1,
      genre_id: 1
    }
  },
  {
    $out: "movies_genres_clean"
  }
])


// =======================
// WATCH_HISTORY → watch_history_clean
// =======================

db.watch_history.aggregate([
  {
    $match: {
      user_id: { $exists: true, $ne: null },
      movie_id: { $exists: true, $ne: null }
    }
  },
  {
    $project: {
      _id: 0,
      user_id: 1,
      movie_id: 1,
      watched_at: 1
    }
  },
  {
    $out: "watch_history_clean"
  }
])










