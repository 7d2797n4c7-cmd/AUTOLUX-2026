DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS vin_requests CASCADE;
DROP TABLE IF EXISTS statistics_daily CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS news CASCADE;
DROP TABLE IF EXISTS cars CASCADE;
DROP TABLE IF EXISTS car_models CASCADE;
DROP TABLE IF EXISTS car_brands CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150),
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30),
    password VARCHAR(255),
    avatar VARCHAR(255),
    role VARCHAR(30) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE car_brands(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image VARCHAR(255)
);

CREATE TABLE car_models(
    id SERIAL PRIMARY KEY,
    brand_id INTEGER REFERENCES car_brands(id) ON DELETE CASCADE,
    name VARCHAR(100),
    image VARCHAR(255)
);

CREATE TABLE cars(
    id SERIAL PRIMARY KEY,
    brand_id INTEGER REFERENCES car_brands(id),
    model_id INTEGER REFERENCES car_models(id),
    title VARCHAR(200),
    year INTEGER,
    engine VARCHAR(100),
    transmission VARCHAR(100),
    fuel VARCHAR(50),
    mileage INTEGER,
    color VARCHAR(100),
    price NUMERIC(12,2),
    image VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products(
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    category VARCHAR(100),
    price NUMERIC(10,2),
    stock INTEGER DEFAULT 0,
    sold INTEGER DEFAULT 0,
    image VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);