-- Remarques !!!
-- Tous le code a été exécuté directement dans l'interface de pgadmin !!!
-- Toutes les tables resteront dans la BD même si elles sont temporaires afin de faciliter la vérification pour la correction.






--##########################################################################################################
-- Création des tables
--##########################################################################################################
-- Les tables finales ont été créée avec l'interface pgadmin 
-- puis, elles ont été clonées sans leurs contraintes afin de faire des tables tampons dont voici le code de clonage
CREATE TABLE public.tampon_table_finale AS 
SELECT *
FROM "table_finale";

-- exemple :
CREATE TABLE public.tampon_workers AS 
SELECT *
FROM "Workers";

-- Cela permettait d'avoir les données dans la base avant de les traiter

-- On a également créé des tables de rejets afin de vérifier que l'on rejetait 
-- uniquement ce qui n'était pas valable et aussi pour en garder une trace
-- (elles sont toutes créées de la même manière donc une seule version de la requête est présentée)

CREATE TABLE public.rejet_workers AS 
SELECT *
FROM "Workers";

-- Les tables tampon et les tables de rejets ne sont plus utiles à la fin du projet (sauf pour la correction éventuellement)


--##########################################################################################################
-- Suppression des doublons dans les tables tampons
--##########################################################################################################
DELETE FROM "tampon_workers" t1
USING "tampon_workers" t2
WHERE t1.ctid < t2.ctid
  AND t1.worker_id = t2.worker_id;


DELETE FROM "tampon_users" t1
USING "tampon_users" t2
WHERE t1.ctid < t2.ctid
  AND t1.user_id = t2.user_id;


DELETE FROM "tampon_movies" t1
USING "tampon_movies" t2
WHERE t1.ctid < t2.ctid
  AND t1.movie_id = t2.movie_id;


DELETE FROM "tampon_awards" t1
USING "tampon_awards" t2
WHERE t1.ctid < t2.ctid
  AND t1.award_id = t2.award_id;


DELETE FROM "tampon_genre" t1
USING "tampon_genre" t2
WHERE t1.ctid < t2.ctid
  AND t1.genre_id = t2.genre_id;


DELETE FROM "tampon_movie_actors" t1
USING "tampon_movie_actors" t2
WHERE t1.ctid < t2.ctid
  AND t1.id = t2.id;


DELETE FROM "tampon_movie_awards" t1
USING "tampon_movie_awards" t2
WHERE t1.ctid < t2.ctid
  AND t1.movie_id = t2.movie_id
  AND t1.award_id = t2.award_id;


DELETE FROM "tampon_movie_genre" t1
USING "tampon_movie_genre" t2
WHERE t1.ctid < t2.ctid
  AND t1.movie_id = t2.movie_id
  AND t1.genre_id = t2.genre_id;


DELETE FROM "tampon_ratings" t1
USING "tampon_ratings" t2
WHERE t1.ctid < t2.ctid
  AND t1.user_id = t2.user_id
  AND t1.movie_id = t2.movie_id;


DELETE FROM "tampon_favorite_genres" t1
USING "tampon_favorite_genres" t2
WHERE t1.ctid < t2.ctid
  AND t1.user_id = t2.user_id
  AND t1.genre_id = t2.genre_id;

--##########################################################################################################
-- Migration des données des tables tampon vers les tables finales
--##########################################################################################################

-- Pour la table "Workers"
INSERT INTO "Workers" (worker_id, nom)
Select worker_id, trim(nom)  --On retire les espaces inutiles sur les côté
FROM "tampon_workers"
WHERE nom is NOT NULL  --On préfère reconnaitre la personne
	AND worker_id is NOT NULL --L'identifiant ne peut être null
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?([ ]V)?$';  --Regex permettant de vérifier que
    -- Le nom (nettoyé des espaces exérieurs) est composé de lettres
    -- Le prénom fait entre 2 et 100 caractères
    -- Le séparateur est soit un espace (on passe au nom), soit une apostrophe (noms américains) 
    -- ou soit un tiret (nom ou prénom composé)
    -- Le(s) mot(s) suivants sont en lettres
    -- Un séparateur est toujours l'un des 3 proposés lorsque l'on change de mot
    -- Une abréviation peut terminer le mot


-- Ceci est la même requête mais sans les commentaires
INSERT INTO "Workers" (worker_id, nom)
Select worker_id, trim(nom)
FROM "tampon_workers"
WHERE nom is NOT NULL
	AND worker_id is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?([ ]V)?$';



-- Pour les noms on ne vérifie pas s'il y a des doublons ou non car nom n'est pas une clé fiable et il n'est pas
-- impossible que 2 personnes différentes portent le même nom et prénom
INSERT INTO "Users" (user_id, nom)
Select user_id, trim(nom)
FROM "tampon_users"
WHERE nom is NOT NULL
	AND user_id is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?([ ]V)?$';


-- Pour les films, nous avons décidé que seuls l'id et le titre devaient être non null car nous somme parti du principe
-- que nous ne somme pas obligés d'avoir plus d'informations pour regarder un film (certaines personnes ne s'y intéressent pas)
-- et que, par conséquent, nous pouvons nous en passer.
-- Nayant pas plus d'informations sur les données contenues dans "metadata", 
-- nous avons décidé de ne pas mettre de condition dessus.
-- Le titre doit être composé de mots et ou de chiffres
-- L'année doit être écrite en 4 chiffres pour être valable ou ne pas être là
INSERT INTO "Movies" (movie_id, titre, année, director_id, metadata)
SELECT 
    t.movie_id,
    trim(t.titre),
    t.année,
    t.director_id,
    t.metadata
FROM "tampon_movies" t
WHERE t.movie_id IS NOT NULL
  AND t.titre IS NOT NULL
  AND trim(t.titre) ~ '^[[:alnum:]]{1,100}([ ''\-][[:alnum:]]{1,100})*$'
  AND (t.année is NULL OR (CAST(t.année AS TEXT) ~ '^[0-9]{4}$') AND t.année > 1800)
  AND (t.director_id IS NULL OR EXISTS (
        SELECT 1
        FROM "Workers" w
        WHERE w.worker_id = t.director_id
  ));



-- Pour cette table, rien ne peut être null car sinon on pourrait perdre de l'information utile.
-- Le nom et la catégorie sont composés d'un ou plusieurs mots
INSERT INTO "Awards" (award_id, nom, catégorie)
Select award_id, trim(nom), catégorie
FROM "tampon_awards"
WHERE award_id is NOT NULL
	AND nom is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{1,100}([ ''\-][[:alpha:]]{1,100})*$'
    AND catégorie is NOT NULL
	AND trim(catégorie) ~ '^[[:alpha:]]{1,100}([ ''\-][[:alpha:]]{1,100})*$';


-- Cette table doit posséder toutes ses informations pour avoir du sens donc rien ne peut être null
-- Le nom doit être composé de mots
INSERT INTO "Genre" (genre_id, nom)
Select genre_id, trim(nom)
FROM "tampon_genre"
WHERE genre_id is NOT NULL
	AND nom is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{1,100}([ ''\-][[:alpha:]]{1,100})*$';


INSERT INTO "Movie_actors" (id, movie_id, actor_id, rôle)
Select t.id, 
	t.movie_id,
	t.actor_id,
	t.rôle
FROM "tampon_movie_actors" t
WHERE t.id is NOT NULL
	AND t.movie_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Movies" m
		WHERE m.movie_id = t.movie_id)
	AND t.actor_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Workers" w
		WHERE w.worker_id = t.actor_id)
	AND (trim(t.rôle) is NULL OR trim(t.rôle) ~ '^[[:alpha:]]{1,100}([ ''/,\-][ ]?[(]?[[:alpha:]]{1,100}[)]?)*$');


INSERT INTO "Movie_awards" (movie_id, award_id, année)
SELECT 
    t.movie_id,
    t.award_id,
    CASE 
        WHEN t.année IS NULL THEN NULL
        WHEN CAST(t.année AS TEXT) ~ '^[0-9]{4}$' THEN t.année
        ELSE NULL
    END AS année
FROM "tampon_movie_awards" t
WHERE t.movie_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Movies" m
	WHERE m.movie_id = t.movie_id)
  AND t.award_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Awards" a
	WHERE a.award_id = t.award_id);


INSERT INTO "Movie_genre" (movie_id, genre_id)
SELECT 
    t.movie_id,
    t.genre_id
FROM "tampon_movie_genre" t
WHERE t.movie_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Movies" m
	WHERE m.movie_id = t.movie_id)
  AND t.genre_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Genre" g
	WHERE g.genre_id = t.genre_id);


-- Nous avons décidé de ne garder que la première instance d'une note étant donné que nous n'avons pas de donnée temporelle
-- et qu'il nous est donc impossible de déterminer qu'elle note est la plus récente pour la garder
-- (ce qui aurait été mieux selon nous). C'est pourquoi les doublons ne sont pas repris dans la table des rejets.
INSERT INTO "Ratings" (user_id, movie_id, rating, review)
Select t.user_id::UUID,
	t.movie_id::UUID,
	t.rating::INTEGER,
	t.review
FROM "tampon_ratings" t
WHERE t.user_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Users" u
		WHERE u.user_id = t.user_id::UUID)
	AND t.movie_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Movies" m
		WHERE m.movie_id = t.movie_id::UUID)
	AND CAST(t.rating as TEXT) ~ '^[0-5]{1}$';


INSERT INTO "Favorite_genres" (user_id, genre_id)
Select t.user_id, 
	t.genre_id
FROM "tampon_favorite_genres" t
WHERE t.user_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Users" u
		WHERE u.user_id = t.user_id)
	AND t.genre_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Genre" g
		WHERE g.genre_id = t.genre_id);


INSERT INTO "Watch_history" (history_id, user_id, movie_id, watched_on)
SELECT 
    t.history_id,
    t.user_id,
    t.movie_id,
    CASE
        WHEN t.watched_on IS NULL THEN NULL
        WHEN t.watched_on BETWEEN DATE '1800-01-01' AND CURRENT_DATE
        THEN t.watched_on
        ELSE NULL
    END AS watched_on
FROM "tampon_watch_history" t
WHERE t.history_id IS NOT NULL
  AND t.user_id IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM "Users" u
        WHERE u.user_id = t.user_id)
  AND t.movie_id IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM "Movies" m
        WHERE m.movie_id = t.movie_id);


--##########################################################################################################
-- Migration des données des tables tampon vers les tables rejets pour vérifier qu'on ne rejette pas trop
--##########################################################################################################

INSERT INTO "rejet_workers" (worker_id, nom)
Select worker_id, trim(nom)
FROM "tampon_workers"
WHERE NOT (nom is NOT NULL
	AND worker_id is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?([ ]V)?$');



INSERT INTO "Users" (user_id, nom)
Select user_id, trim(nom)
FROM "tampon_users"
WHERE NOT (nom is NOT NULL
	AND user_id is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?([ ]V)?$');


INSERT INTO "rejet_movies" (movie_id, titre, année, director_id, metadata)
SELECT 
    t.movie_id,
    trim(t.titre),
    t.année,
    t.director_id,
    t.metadata
FROM "tampon_movies" t
WHERE NOT (t.movie_id IS NOT NULL
  AND t.titre IS NOT NULL
  AND trim(t.titre) ~ '^[[:alnum:]]{1,100}([ ''\-][[:alnum:]]{1,100})*$'
  AND (t.année is NULL OR (CAST(t.année AS TEXT) ~ '^[0-9]{4}$') AND t.année > 1800)
  AND (t.director_id IS NULL OR EXISTS (
        SELECT 1
        FROM "Workers" w
        WHERE w.worker_id = t.director_id
  )));


INSERT INTO "rejet_awards" (award_id, nom, catégorie)
Select award_id, trim(nom), catégorie
FROM "tampon_awards"
WHERE NOT (award_id is NOT NULL
	AND nom is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{1,100}([ ''\-][[:alpha:]]{1,100})*$'
    AND catégorie is NOT NULL
	AND trim(catégorie) ~ '^[[:alpha:]]{1,100}([ ''\-][[:alpha:]]{1,100})*$');


INSERT INTO "rejet_genre" (genre_id, nom)
Select genre_id, trim(nom)
FROM "tampon_genre"
WHERE NOT (genre_id is NOT NULL
	AND nom is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{1,100}([ ''\-][[:alpha:]]{1,100})*$');


INSERT INTO "rejet_movie_actors" (id, movie_id, actor_id, rôle)
Select t.id, 
	t.movie_id,
	t.actor_id,
	t.rôle
FROM "tampon_movie_actors" t
WHERE NOT (id is NOT NULL
	AND t.movie_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Movies" m
		WHERE m.movie_id = t.movie_id)
	AND t.actor_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Workers" w
		WHERE w.worker_id = t.actor_id)
	AND (trim(t.rôle) is NULL OR trim(t.rôle) ~ '^[[:alpha:]]{1,100}([ ''/,\-][ ]?[(]?[[:alpha:]]{1,100}[)]?)*$'));


INSERT INTO "rejet_movie_awards" (movie_id, award_id, année)
SELECT 
    t.movie_id,
    t.award_id,
    CASE 
        WHEN t.année IS NULL THEN NULL
        WHEN CAST(t.année AS TEXT) ~ '^[0-9]{4}$' THEN t.année
        ELSE NULL
    END AS année
FROM "tampon_movie_awards" t
WHERE NOT (t.movie_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Movies" m
	WHERE m.movie_id = t.movie_id)
  AND t.award_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Awards" a
	WHERE a.award_id = t.award_id));


INSERT INTO "rejet_movie_genre" (movie_id, genre_id)
SELECT 
    t.movie_id,
    t.genre_id
FROM "tampon_movie_genre" t
WHERE NOT(t.movie_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Movies" m
	WHERE m.movie_id = t.movie_id)
  AND t.genre_id IS NOT NULL
  AND EXISTS (
	SELECT 1
	FROM "Genre" g
	WHERE g.genre_id = t.genre_id));


INSERT INTO "rejet_ratings" (user_id, movie_id, rating, review)
SELECT 
    CASE 
        WHEN t.user_id ~ '^[0-9a-fA-F-]{36}$'
        THEN t.user_id::UUID
        ELSE NULL
    END,
    CASE 
        WHEN t.movie_id ~ '^[0-9a-fA-F-]{36}$'
        THEN t.movie_id::UUID
        ELSE NULL
    END,
    CASE
        WHEN t.rating ~ '^[0-5]{1}$'
        THEN t.rating::INTEGER
        ELSE NULL
    END,
    t.review
FROM "tampon_ratings" t
WHERE NOT (t.user_id IS NOT NULL
    AND EXISTS (
        SELECT 1
        FROM "Users" u
        WHERE u.user_id = t.user_id::UUID)
    AND t.movie_id IS NOT NULL

    AND EXISTS (SELECT 1
        FROM "Movies" m
        WHERE m.movie_id = t.movie_id::UUID)
    AND t.rating ~ '^[0-5]{1}$');


INSERT INTO "rejet_favorite_genres" (user_id, genre_id)
Select t.user_id, 
	t.genre_id
FROM "tampon_favorite_genres" t
WHERE NOT (t.user_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Users" u
		WHERE u.user_id = t.user_id)
	AND t.genre_id is NOT NULL
	AND EXISTS (
		Select 1
		FROM "Genre" g
		WHERE g.genre_id = t.genre_id));


INSERT INTO "rejet_watch_history" (history_id, user_id, movie_id, watched_on)
SELECT 
    t.history_id,
    t.user_id,
    t.movie_id,
    CASE
        WHEN t.watched_on IS NULL THEN NULL
        WHEN t.watched_on BETWEEN DATE '1800-01-01' AND CURRENT_DATE
        THEN t.watched_on
        ELSE NULL
    END AS watched_on
FROM "tampon_watch_history" t
WHERE NOT (t.history_id IS NOT NULL
  AND t.user_id IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM "Users" u
        WHERE u.user_id = t.user_id)
  AND t.movie_id IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM "Movies" m
        WHERE m.movie_id = t.movie_id));



--##########################################################################################################
-- Requêtes de l'énoncé
--##########################################################################################################

-- Trouver les films avec une note moyenne supérieure à 4.5
-- Temps d'exécution = 4.003 secondes
SELECT m.movie_id, m.titre
FROM "Movies" m
JOIN "Ratings" r
	ON m.movie_id = r.movie_id
GROUP BY m.movie_id
HAVING AVG(r.rating) > 4.5;




-- Récupérer toutes les informations d'un film avec ses acteurs, son directeur et
-- ses récompenses.
-- Temps d'exécution = 19.138 secondes
SELECT m.titre AS Titre, 
	m.année AS Année, 
	m.metadata AS Informations_supplémentaires, 
	w1.nom AS Directeur, 
	ma2.Acteurs, 
	mw2.Récompenses
FROM "Movies" m
LEFT JOIN (
	SELECT worker_id, nom
	FROM "Workers") w1
	ON w1.worker_id = m.director_id

LEFT JOIN (
    SELECT ma1.movie_id,
        STRING_AGG(DISTINCT w.nom, ', ') AS Acteurs
    FROM "Movie_actors" ma1
    JOIN "Workers" w
        ON w.worker_id = ma1.actor_id
    GROUP BY ma1.movie_id) ma2
	ON ma2.movie_id = m.movie_id

LEFT JOIN (
	SELECT mw1.movie_id,
		STRING_AGG(DISTINCT a.nom || '(' || a.catégorie || ')', ', ') AS Récompenses
	FROM "Movie_awards" mw1
	LEFT JOIN (
		Select nom, catégorie, award_id
		FROM "Awards") a
		ON a.award_id = mw1.award_id
	GROUP BY mw1.movie_id) mw2
	ON mw2.movie_id = m.movie_id;




-- Trouver des films non regardés par un utilisateur ayant des acteurs qui ont
-- joué dans des films qu'il a déjà regardés
-- Temps d'exécution = 4 minutes 8.442 secondes
SELECT u.user_id, 
	STRING_AGG(DISTINCT m.titre || '[' || m.movie_id || ']', ', ')
FROM "Users" u
JOIN (
	SELECT user_id,
		movie_id
	FROM "Watch_history") wh
	ON wh.user_id = u.user_id

JOIN (
	SELECT actor_id, movie_id
	FROM "Movie_actors") ma
	ON ma.movie_id = wh.movie_id

JOIN (
	SELECT movie_id, actor_id
	FROM "Movie_actors") ma2
	ON (ma2.actor_id = ma.actor_id AND ma2.movie_id <> wh.movie_id)
	
JOIN (
	SELECT titre, movie_id
	FROM "Movies") m
	ON m.movie_id = ma2.movie_id

WHERE NOT EXISTS (
    SELECT 1
    FROM "Watch_history" wh2
    WHERE wh2.user_id = u.user_id
      AND wh2.movie_id = m.movie_id
)
	
GROUP BY u.user_id;