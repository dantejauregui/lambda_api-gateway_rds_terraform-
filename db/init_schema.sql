CREATE TABLE IF NOT EXISTS users (
  name TEXT NOT NULL,
  favorite_movie TEXT
);

-- Insert 10 dummy rows
INSERT INTO users (name, favorite_movie) VALUES
('Alice', 'Titanic'),
('Bob', 'Inception'),
('Charlie', 'The Matrix'),
('Diana', 'Interstellar'),
('Eve', 'The Godfather'),
('Frank', 'Jurassic Park'),
('Grace', 'Forrest Gump'),
('Heidi', 'Gladiator'),
('Ivan', 'Pulp Fiction'),
('Judy', 'The Shawshank Redemption');
