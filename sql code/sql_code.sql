PRAGMA foreign_keys = ON;

-- Ingredients available in market inventory
CREATE TABLE ingredients (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  name      TEXT NOT NULL,   
  shop      TEXT NOT NULL,   
  cost      REAL NOT NULL,
  distance  REAL NOT NULL,
  calories  INTEGER NOT NULL,

  UNIQUE(name, shop)
);

-- Recipes
CREATE TABLE recipes (
  id    TEXT PRIMARY KEY,  
  name  TEXT NOT NULL
);

CREATE TABLE recipe_ingredients (
  recipe_id     TEXT NOT NULL,
  ingredient_id INTEGER NOT NULL,

  PRIMARY KEY (recipe_id, ingredient_id),
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);

CREATE INDEX idx_ingredients_name ON ingredients(name);
CREATE INDEX idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id);


-- Insert mock inventory
INSERT INTO ingredients (name, shop, cost, distance, calories) VALUES
  ('Flour',    'Aldi',     0.80, 3.0, 360),
  ('Milk',     'Waitrose', 1.80, 1.0, 45),
  ('Eggs',     'Value',    1.50, 0.5, 155),
  ('Lettuce',  'Fresh',    1.00, 0.2, 15),
  ('Tomatoes', 'Generic',  1.50, 0.2, 18),
  ('Cucumber', 'Generic',  0.80, 0.2, 16),
  ('Pasta',    'Basic',    0.50, 2.0, 131);


-- Insert recipes
INSERT INTO recipes (id, name) VALUES
  ('r-1', 'Scrambled Eggs on Toast'),
  ('r-2', 'Tomato & Cucumber Salad'),
  ('r-3', 'Simple Pasta');


-- Link recipes to required ingredients (by ingredient name)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id)
SELECT 'r-1', i.id
FROM ingredients i
WHERE i.name IN ('Eggs', 'Milk', 'Flour')
AND i.id = (SELECT MIN(id) FROM ingredients WHERE name = i.name);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id)
SELECT 'r-2', i.id
FROM ingredients i
WHERE i.name IN ('Tomatoes', 'Cucumber', 'Lettuce')
AND i.id = (SELECT MIN(id) FROM ingredients WHERE name = i.name);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id)
SELECT 'r-3', i.id
FROM ingredients i
WHERE i.name IN ('Pasta', 'Tomatoes', 'Milk')
AND i.id = (SELECT MIN(id) FROM ingredients WHERE name = i.name);
