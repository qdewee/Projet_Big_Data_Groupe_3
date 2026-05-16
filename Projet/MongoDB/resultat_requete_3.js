//Premier test avec collection recommendations_by_actor donne un temps d'exécution trop élevé (88 minutes)


  inprog: [
    {
      type: 'op',
      host: '94a1d591de25:27017',
      desc: 'conn13',
      connectionId: 13,
      client: '127.0.0.1:36892',
      appName: 'mongosh 2.8.2',
      clientMetadata: {
        application: { name: 'mongosh 2.8.2' },
        driver: { name: 'nodejs|mongosh', version: '7.1.0|2.8.2' },
        platform: 'Node.js v24.14.1, LE',
        os: {
          name: 'linux',
          architecture: 'x64',
          version: '3.10.0-327.22.2.el7.x86_64',
          type: 'Linux'
        },
        env: { container: { runtime: 'docker' } }
      },
      active: true,
      currentOpTime: '2026-05-16T19:53:41.591+00:00',
      effectiveUsers: [ { user: 'root', db: 'admin' } ],
      isFromUserConnection: true,
      threaded: true,
      opid: 405524,
      lsid: {
        id: UUID('aceb4ffd-8bcf-4d44-ad88-29fd9286ad1d'),
        uid: Binary.createFromBase64('Y5mrDaxi8gv8RmdTsQ+1j7fmkr7JUsabhNmXAheU0fg=', 0)
      },
      secs_running: Long('5299'),
      microsecs_running: Long('5299592594'),
      op: 'command',
      ns: 'movies_project.tmp.agg_out.90aa7c56-d3fb-4753-a384-7857df15e2e9',
      redacted: false,
      command: {
        aggregate: 'user_seen_actors',
        pipeline: [
          { '$unwind': '$actor_ids' },
          {
            '$lookup': {
              from: 'movies_actors_clean',
              localField: 'actor_ids',
              foreignField: 'actor_id',
              as: 'candidate_movies'
            }
          },
          { '$unwind': '$candidate_movies' },
          {
            '$match': {
              '$expr': {
                '$not': { '$in': [ '$candidate_movies.movie_id', '$watched_movie_ids' ] }
              }
            }
          },
          {
            '$group': {
              _id: { user_id: '$user_id', movie_id: '$candidate_movies.movie_id' },
              matching_actor_ids: { '$addToSet': '$actor_ids' }
            }
          },
          {
            '$lookup': {
              from: 'users_clean',
              localField: '_id.user_id',
              foreignField: 'id',
              as: 'user'
            }
          },
          { '$unwind': '$user' },
          {
            '$lookup': {
              from: 'movies_clean',
              localField: '_id.movie_id',
              foreignField: 'id',
              as: 'movie'
            }
          },
          { '$unwind': '$movie' },
          {
            '$lookup': {
              from: 'workers_clean',
              localField: 'movie.director_id',
              foreignField: 'id',
              as: 'director'
            }
          },
          { '$unwind': { path: '$director', preserveNullAndEmptyArrays: true } },
          {
            '$project': {
              _id: 0,
              user_id: '$_id.user_id',
              user_name: '$user.name',
              movie_id: '$_id.movie_id',
              title: '$movie.title',
              year: '$movie.year',
              director: '$director.name',
              matching_actor_ids: 1,
              matching_actor_count: { '$size': '$matching_actor_ids' }
            }
          },
          { '$sort': { user_id: 1, matching_actor_count: -1, year: -1 } },
          { '$out': 'recommendations_by_actor' }
        ],
        cursor: {},
        lsid: { id: UUID('aceb4ffd-8bcf-4d44-ad88-29fd9286ad1d') },
        '$db': 'movies_project'
      },
      queryFramework: 'classic',
      planSummary: 'COLLSCAN',
      numYields: 3210,
      delinquencyInfo: {
        totalDelinquentAcquisitions: 38,
        totalAcquisitionDelinquencyMillis: Long('2093'),
        maxAcquisitionDelinquencyMillis: Long('197')
      },
      numInterruptChecks: Long('122300352'),
      queues: {
        ingress: {
          admissions: 1,
          totalTimeQueuedMicros: Long('0'),
          isHoldingTicket: true
        },
        execution: {
          admissions: 79774321,
          totalTimeQueuedMicros: Long('0'),
          isHoldingTicket: true
        }
      },
      currentQueue: null,
      queryShapeHash: 'C0957E016FC3E88F371073DBDE9D1621F33159FBBAEA4A2067D42824488961B8',
      locks: { Global: 'r' },
      waitingForLock: false,
      lockStats: {
        ReplicationStateTransition: { acquireCount: { w: Long('1') } },
        Global: { acquireCount: { r: Long('79774320'), w: Long('1') } },
        Database: { acquireCount: { w: Long('1') } },
        Collection: { acquireCount: { w: Long('1') } }
      },
      waitingForFlowControl: false,
      flowControlStats: { acquireCount: Long('1') }
    }
  ],
  ok: 1
}















