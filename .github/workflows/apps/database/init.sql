CREATE TABLE IF NOT EXISTS contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

INSERT INTO contacts (name, phone) VALUES
    ('Alice', '123-456-7890'),
    ('Bob', '987-654-3210');
