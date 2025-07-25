DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  favorite_movie TEXT
);

-- Insert 10 dummy rows for Testing purposes:
INSERT INTO users (id, name, favorite_movie) VALUES
(1, 'Alice', 'Titanic'),
(2, 'Bob', 'Inception'),
(3, 'Charlie', 'The Matrix'),
(4, 'Diana', 'Interstellar'),
(5, 'Eve', 'The Godfather'),
(6, 'Frank', 'Jurassic Park'),
(7, 'Grace', 'Forrest Gump'),
(8, 'Heidi', 'Gladiator'),
(9, 'Ivan', 'Pulp Fiction'),
(10, 'Judy', 'The Shawshank Redemption');

-- This ensures that the SERIAL sequence (users_id_seq) is properly updated to start at the highest id + 1, avoiding any duplicate key errors on future INSERT statements:
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));