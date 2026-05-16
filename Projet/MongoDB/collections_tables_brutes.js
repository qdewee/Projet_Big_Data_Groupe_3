// Crée la collection awards
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\awards.json" mongodb:/tmp/awards.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection awards --drop --file /tmp/awards.json --jsonArray


//Crée la collection favorite_genres
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\favorite_genres.json" mongodb:/tmp/favorite_genres.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection favorite_genres --drop --file /tmp/favorite_genres.json --jsonArray


//Crée la collection movies
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\movies.json" mongodb:/tmp/movies.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection movies --drop --file /tmp/movies.json --jsonArray


//Crée la collection workers
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\workers.json" mongodb:/tmp/workers.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection workers --drop --file /tmp/workers.json --jsonArray


//Crée la collection genres
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\genres.json" mongodb:/tmp/genres.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection genres --drop --file /tmp/genres.json --jsonArray


//Crée la collection movies_actors
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\movies_actors.json" mongodb:/tmp/movies_actors.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection movies_actors --drop --file /tmp/movies_actors.json --jsonArray


//Crée la collection movies_awards
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\movies_awards.json" mongodb:/tmp/movies_awards.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection movies_awards --drop --file /tmp/movies_awards.json --jsonArray


//Crée la collection movies_genres
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\movies_genres.json" mongodb:/tmp/movies_genres.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection movies_genres --drop --file /tmp/movies_genres.json --jsonArray


//Crée la collection ratings
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\ratings.json" mongodb:/tmp/ratings.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection ratings --drop --file /tmp/ratings.json --jsonArray


//Crée la collection users
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\users.json" mongodb:/tmp/users.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection users --drop --file /tmp/users.json --jsonArray


//Crée la collection watch_history
docker cp "D:\UNAMUR\data\generated_data\large\mongodb\watch_history.json" mongodb:/tmp/watch_history.json

docker exec -it mongodb mongoimport --username root --password example --authenticationDatabase admin --db movies_project --collection watch_history --drop --file /tmp/watch_history.json --jsonArray




  

