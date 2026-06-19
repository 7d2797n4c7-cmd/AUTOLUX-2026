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
CREATE TABLE news(

    id SERIAL PRIMARY KEY,

    title TEXT,

    description TEXT,

    image TEXT,

    link TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE promotions(

    id SERIAL PRIMARY KEY,

    title VARCHAR(200),

    description TEXT,

    image TEXT,

    discount INTEGER,

    promo_code VARCHAR(50),

    active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE vin_requests(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    vin VARCHAR(50),

    phone VARCHAR(30),

    comment TEXT,

    status VARCHAR(50) DEFAULT 'Новая',

    answer TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE statistics_daily(

    id SERIAL PRIMARY KEY,

    stat_date DATE,

    revenue NUMERIC(12,2) DEFAULT 0,

    orders INTEGER DEFAULT 0,

    new_users INTEGER DEFAULT 0,

    vin_requests INTEGER DEFAULT 0

);

CREATE TABLE orders(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    full_name VARCHAR(150),

    phone VARCHAR(30),

    address TEXT,

    city VARCHAR(100),

    payment VARCHAR(100),

    comment TEXT,

    status VARCHAR(50) DEFAULT 'Новая',

    total_price NUMERIC(12,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE order_items(

    id SERIAL PRIMARY KEY,

    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,

    product_id INTEGER REFERENCES products(id),

    quantity INTEGER,

    price NUMERIC(12,2)

);
INSERT INTO car_brands(name,image) VALUES

('BMW','/static/brands/bmw.png'),
('Mercedes-Benz','/static/brands/mercedes.png'),
('Audi','/static/brands/audi.png'),
('Toyota','/static/brands/toyota.png'),
('Kia','/static/brands/kia.png'),
('Hyundai','/static/brands/hyundai.png'),
('Chevrolet','/static/brands/chevrolet.png'),
('Volkswagen','/static/brands/volkswagen.png');
INSERT INTO car_models(brand_id,name) VALUES

(1,'3 Series'),
(1,'5 Series'),
(1,'X5'),

(2,'C-Class'),
(2,'E-Class'),

(3,'A4'),
(3,'Q7'),

(4,'Camry'),
(4,'Land Cruiser'),

(5,'Sportage'),
(6,'Tucson'),
(7,'Tracker'),
(8,'Passat');
INSERT INTO products(

title,
category,
price,
stock,
sold,
image,
description

)

VALUES

('Масло Motul 5W30','Масла',24500,35,12,'/static/products/motul.webp','Полностью синтетическое масло'),

('Тормозные колодки Brembo','Тормоза',38900,18,7,'/static/products/brembo.webp','Передние колодки'),

('Фильтр Mahle','Фильтры',8500,50,15,'/static/products/filter.webp','Воздушный фильтр'),

('Свечи NGK','Двигатель',6400,70,21,'/static/products/ngk.webp','Комплект свечей'),

('LED Лампы','Освещение',12000,25,9,'/static/products/led.webp','Комплект LED'),

('Android Магнитола','Электроника',139000,8,5,'/static/products/android.webp','10 дюймов');
INSERT INTO promotions(

title,
description,
image,
discount,
promo_code

)

VALUES

(

'Летняя акция',

'Скидка на все масла',

'/static/promo1.jpg',

20,

'SUMMER20'

),

(

'Тормозная система',

'Скидка Brembo',

'/static/promo2.jpg',

15,

'BREMBO15'

);
INSERT INTO users(

full_name,
email,
phone,
password,
role

)

VALUES

(

'Administrator',

'admin@autolux.kz',

'+77000000000',

'admin',

'admin'

);