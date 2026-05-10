-- Remarques !!!
-- Tous le code a été exécuté directement dans l'interface de pgadmin !!!
-- Toutes les tables resteront dans la BD même si elles sont temporaires afin de faciliter la vérification pour la correction.






--#################################################################################
-- Création des tables
--#################################################################################
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

-- Les tables tampon et les tables de rejets sont supprimées à la fin du projet

--#################################################################################
-- Migration des données des tables tampon vers les tables finales
--#################################################################################

-- Pour la table "Workers"
INSERT INTO "Workers" (worker_id, nom)
Select worker_id, trim(nom)  --On retire les espaces inutiles sur les côté
FROM "tampon_workers"
WHERE nom is NOT NULL  --On préfère reconnaitre la personne
	AND worker_id is NOT NULL --L'identifiant ne peut être null
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?$'  --Regex permettant de vérifier que
    -- Le nom (nettoyé des espaces exérieurs) est composé de lettres
    -- Le prénom fait entre 2 et 100 caractères
    -- Le séparateur est soit un espace (on passe au nom), soit une apostrophe (noms américains) 
    -- ou soit un tiret (nom ou prénom composé)
    -- Le(s) mot(s) suivants sont en lettres
    -- Un séparateur est toujours l'un des 3 proposés lorsque l'on change de mot
    -- Une abréviation peut terminer le mot
ON conflict(worker_id) DO NOTHING;  -- En cas de conflic entre les identifiants, on ne les prends pas en compte 
                                    -- pour éviter les identifiants doublons


-- Ceci est la même requête mais sans les commentaires
INSERT INTO "Workers" (worker_id, nom)
Select worker_id, trim(nom)
FROM "tampon_workers"
WHERE nom is NOT NULL
	AND worker_id is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?$'
ON conflict(worker_id) DO NOTHING;



-- Pour les noms on ne vérifie pas s'il y a des doublons ou non car nom n'est pas une clé fiable et il n'est pas
-- impossible que 2 personnes différentes portent le même nom et prénom
INSERT INTO "Users" (user_id, nom)
Select user_id, trim(nom)
FROM "tampon_users"
WHERE nom is NOT NULL
	AND user_id is NOT NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?$'
ON conflict(user_id) DO NOTHING;


-- Pour les films, nous avons décidé que seuls l'id et le titre devaient être non null car nous somme parti du principe
-- que nous ne somme pas obligés d'avoir plus d'informations pour regarder un film (certaines personnes ne s'y intéressent pas)
-- et que, par conséquent, nous pouvons nous en passer.
-- Nayant pas plus d'informations sur les données contenues dans "metadata", 
-- nous avons décidé de ne pas mettre de condition dessus.
-- Le titre doit être composé de mots et ou de chiffres
-- L'année doit être écrite en 4 chiffres pour être valable ou ne pas être là
-- ATTENTION
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
WHERE id is NOT NULL
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
        ELSE 0000
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


--##########################################################################################################
-- Migration des données des tables tampon vers les tables rejets pour vérifier qu'on ne rejette pas trop
--##########################################################################################################

INSERT INTO "rejet_workers" (worker_id, nom)
Select worker_id, trim(nom)
FROM "tampon_workers"
WHERE NOT(nom is NULL
	AND worker_id is NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?$')
ON conflict(worker_id) DO NOTHING;



INSERT INTO "rejet_users" (user_id, nom)
Select user_id, trim(nom)
FROM "tampon_users"
WHERE NOT(nom is NULL
	AND user_id is NULL
	AND trim(nom) ~ '^[[:alpha:]]{2,100}[.]?([ ''\-][[:alpha:]]{2,100})*([ ]Jr\.)?([ ]Sr\.)?$')
ON conflict(user_id) DO NOTHING;


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
        ELSE 0000
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