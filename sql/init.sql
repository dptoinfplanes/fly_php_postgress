CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);

-- Usamos esta sintaxis para evitar errores si los datos ya existen
INSERT INTO users (name) VALUES ('Admin');
INSERT INTO users (name) VALUES  ('User');
