CREATE TABLE orders (
  id   VARCHAR(255)  NOT NULL PRIMARY KEY,
  price FLOAT,
  tax FLOAT,
  final_price FLOAT
);