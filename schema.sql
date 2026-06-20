DROP TABLE IF EXISTS logs CASCADE;
DROP TABLE IF EXISTS statistics_daily CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS vin_requests CASCADE;
DROP TABLE IF EXISTS product_reviews CASCADE;
DROP TABLE IF EXISTS customer_stats CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS cart CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;
DROP TABLE IF EXISTS delivery_cities CASCADE;
DROP TABLE IF EXISTS order_statuses CASCADE;
DROP TABLE IF EXISTS car_models CASCADE;
DROP TABLE IF EXISTS car_brands CASCADE;
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users(

    id SERIAL PRIMARY KEY,

    username VARCHAR(100) UNIQUE NOT NULL,

    email VARCHAR(150),

    password TEXT NOT NULL,

    phone VARCHAR(50),

    avatar TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE car_brands(

    id SERIAL PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    image TEXT

);
CREATE TABLE car_models(

    id SERIAL PRIMARY KEY,

    brand_id INTEGER REFERENCES car_brands(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL

);
CREATE TABLE categories(

    id SERIAL PRIMARY KEY,

    name VARCHAR(120) NOT NULL

);
CREATE TABLE products(

    id SERIAL PRIMARY KEY,

    model_id INTEGER REFERENCES car_models(id),

    category_id INTEGER REFERENCES categories(id),

    title TEXT NOT NULL,

    description TEXT,

    brand VARCHAR(120),

    article VARCHAR(120),

    image TEXT,

    price NUMERIC(12,2) DEFAULT 0,

    stock INTEGER DEFAULT 0,

    sold INTEGER DEFAULT 0,

    views INTEGER DEFAULT 0,

    rating NUMERIC(3,2) DEFAULT 5,

    active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE order_statuses(

    id SERIAL PRIMARY KEY,

    name VARCHAR(50) NOT NULL,

    color VARCHAR(30)

);

INSERT INTO order_statuses(name,color) VALUES
('Новый','#0ea5e9'),
('В обработке','#f59e0b'),
('Оплачен','#22c55e'),
('Отправлен','#3b82f6'),
('Доставлен','#16a34a'),
('Отменён','#ef4444');
CREATE TABLE delivery_cities(

    id SERIAL PRIMARY KEY,

    name VARCHAR(100),

    delivery_price NUMERIC(10,2),

    delivery_days VARCHAR(30)

);

INSERT INTO delivery_cities(name,delivery_price,delivery_days) VALUES
('Астана',2500,'1-2 дня'),
('Алматы',2500,'1-2 дня'),
('Караганда',2500,'1-2 дня'),
('Кокшетау',1500,'1 день'),
('Шымкент',3000,'2-3 дня');
CREATE TABLE payment_methods(

    id SERIAL PRIMARY KEY,

    name VARCHAR(100)

);

INSERT INTO payment_methods(name) VALUES
('Kaspi'),
('Visa / MasterCard'),
('Наличными');
CREATE TABLE cart(

    id SERIAL PRIMARY KEY,

    username VARCHAR(100),

    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,

    qty INTEGER DEFAULT 1

);
CREATE TABLE orders(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    status_id INTEGER REFERENCES order_statuses(id),

    city_id INTEGER REFERENCES delivery_cities(id),

    payment_method_id INTEGER REFERENCES payment_methods(id),

    full_name VARCHAR(200),

    phone VARCHAR(50),

    address TEXT,

    comment TEXT,

    total_price NUMERIC(12,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE order_items(

    id SERIAL PRIMARY KEY,

    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,

    product_id INTEGER REFERENCES products(id),

    quantity INTEGER,

    price NUMERIC(12,2)

);
CREATE INDEX idx_products_model
ON products(model_id);

CREATE INDEX idx_products_title
ON products(title);

CREATE INDEX idx_orders_user
ON orders(user_id);

CREATE INDEX idx_orders_status
ON orders(status_id);

CREATE INDEX idx_cart_username
ON cart(username);
CREATE TABLE customer_stats(

    id SERIAL PRIMARY KEY,

    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,

    total_orders INTEGER DEFAULT 0,

    total_spent NUMERIC(12,2) DEFAULT 0,

    average_check NUMERIC(12,2) DEFAULT 0,

    last_order TIMESTAMP

);
CREATE TABLE product_reviews(

    id SERIAL PRIMARY KEY,

    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,

    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,

    rating INTEGER DEFAULT 5,

    review TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE vin_requests(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    vin VARCHAR(50) NOT NULL,

    phone VARCHAR(50),

    comment TEXT,

    answer TEXT,

    status VARCHAR(50) DEFAULT 'Новая',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE promotions(

    id SERIAL PRIMARY KEY,

    title VARCHAR(255),

    description TEXT,

    image TEXT,

    discount_percent INTEGER,

    promo_code VARCHAR(50),

    date_start DATE,

    date_end DATE,

    active BOOLEAN DEFAULT TRUE

);
CREATE TABLE logs(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    action TEXT,

    ip VARCHAR(60),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE statistics_daily(

    id SERIAL PRIMARY KEY,

    stat_date DATE UNIQUE,

    revenue NUMERIC(12,2) DEFAULT 0,

    orders INTEGER DEFAULT 0,

    new_users INTEGER DEFAULT 0,

    vin_requests INTEGER DEFAULT 0

);
CREATE INDEX idx_review_product
ON product_reviews(product_id);

CREATE INDEX idx_vin_status
ON vin_requests(status);

CREATE INDEX idx_logs_user
ON logs(user_id);

CREATE INDEX idx_stats_date
ON statistics_daily(stat_date);
INSERT INTO categories(name) VALUES
('Двигатель'),
('Подвеска'),
('Тормозная система'),
('Фильтры'),
('Масла'),
('Освещение'),
('Электрика'),
('Кузов'),
('Салон'),
('Аксессуары');
INSERT INTO car_brands(name,image) VALUES
('Toyota','toyota.png'),
('BMW','bmw.png'),
('Mercedes-Benz','mercedes.png'),
('Audi','audi.png'),
('Volkswagen','volkswagen.png'),
('Kia','kia.png'),
('Hyundai','hyundai.png'),
('Chevrolet','chevrolet.png'),
('Lexus','lexus.png'),
('Nissan','nissan.png');
INSERT INTO car_models(brand_id,name) VALUES
(1,'Camry'),
(1,'Corolla'),
(2,'X5'),
(2,'320'),
(3,'E-Class'),
(3,'C-Class'),
(4,'A6'),
(5,'Passat'),
(6,'Sportage'),
(7,'Tucson'),
(8,'Tracker'),
(9,'RX350'),
(10,'X-Trail');
INSERT INTO payment_methods(name)
SELECT 'Kaspi'
WHERE NOT EXISTS(
SELECT 1 FROM payment_methods WHERE name='Kaspi');

INSERT INTO payment_methods(name)
SELECT 'Visa / MasterCard'
WHERE NOT EXISTS(
SELECT 1 FROM payment_methods WHERE name='Visa / MasterCard');

INSERT INTO payment_methods(name)
SELECT 'Наличными'
WHERE NOT EXISTS(
SELECT 1 FROM payment_methods WHERE name='Наличными');
INSERT INTO delivery_cities(name,delivery_price,delivery_days)
SELECT 'Астана',2500,'1-2 дня'
WHERE NOT EXISTS(
SELECT 1 FROM delivery_cities WHERE name='Астана');

INSERT INTO delivery_cities(name,delivery_price,delivery_days)
SELECT 'Алматы',2500,'1-2 дня'
WHERE NOT EXISTS(
SELECT 1 FROM delivery_cities WHERE name='Алматы');

INSERT INTO delivery_cities(name,delivery_price,delivery_days)
SELECT 'Шымкент',3000,'2-3 дня'
WHERE NOT EXISTS(
SELECT 1 FROM delivery_cities WHERE name='Шымкент');

INSERT INTO delivery_cities(name,delivery_price,delivery_days)
SELECT 'Караганда',2500,'1-2 дня'
WHERE NOT EXISTS(
SELECT 1 FROM delivery_cities WHERE name='Караганда');

INSERT INTO delivery_cities(name,delivery_price,delivery_days)
SELECT 'Кокшетау',1500,'1 день'
WHERE NOT EXISTS(
SELECT 1 FROM delivery_cities WHERE name='Кокшетау');
INSERT INTO products
(
model_id,
category_id,
title,
description,
brand,
article,
image,
price,
stock,
sold,
views,
rating,
active
)
VALUES

(
11,
5,
'Liqui Moly 5W-30',
'Полностью синтетическое моторное масло',
'Liqui Moly',
'LM-530',
'/static/products/liquimoly.webp',
14500,
25,
34,
240,
4.9,
TRUE
),

(
11,
4,
'Воздушный фильтр Mahle',
'Оригинальный фильтр',
'Mahle',
'MA-203',
'/static/products/filter.webp',
5500,
40,
28,
180,
4.8,
TRUE
),

(
11,
3,
'Колодки Brembo',
'Передние тормозные колодки',
'Brembo',
'BR-440',
'/static/products/brembo.webp',
22000,
18,
19,
120,
5,
TRUE
),

(
11,
6,
'LED лампы',
'Комплект светодиодных ламп',
'Osram',
'LED-9005',
'/static/products/LED.webp',
12900,
35,
17,
145,
4.7,
TRUE
),

(
11,
9,
'Android магнитола',
'9-дюймовая мультимедиа',
'Teyes',
'CC3',
'/static/products/android.webp',
129900,
6,
11,
96,
4.9,
TRUE
);
INSERT INTO promotions
(
title,
description,
image,
discount_percent,
promo_code,
date_start,
date_end,
active
)
VALUES

(
'Летняя распродажа',
'Скидка на все масла и фильтры',
'/static/images/promo1.jpg',
15,
'SUMMER15',
CURRENT_DATE,
CURRENT_DATE + INTERVAL '30 day',
TRUE
),

(
'Тормозная система',
'Скидка на Brembo',
'/static/images/promo2.jpg',
20,
'BREMBO20',
CURRENT_DATE,
CURRENT_DATE + INTERVAL '20 day',
TRUE
),

(
'Первый заказ',
'Скидка новым клиентам',
'/static/images/promo3.jpg',
10,
'WELCOME10',
CURRENT_DATE,
CURRENT_DATE + INTERVAL '365 day',
TRUE
);
INSERT INTO vin_requests
(
user_id,
vin,
phone,
comment,
status
)
VALUES

(
NULL,
'JTMHZ09J705123456',
'+77001234567',
'Нужны оригинальные фильтры',
'Новая'
),

(
NULL,
'WBAFR91030C123456',
'+77005554433',
'Интересуют тормозные диски',
'В обработке'
);
INSERT INTO statistics_daily
(
stat_date,
revenue,
orders,
new_users,
vin_requests
)
VALUES

(CURRENT_DATE-6,820000,5,2,1),
(CURRENT_DATE-5,910000,8,3,0),
(CURRENT_DATE-4,760000,4,1,2),
(CURRENT_DATE-3,1250000,10,5,1),
(CURRENT_DATE-2,990000,7,2,3),
(CURRENT_DATE-1,1430000,11,6,2),
(CURRENT_DATE,1680000,13,8,4);
INSERT INTO customer_stats
(
user_id,
total_orders,
total_spent,
average_check
)
SELECT

id,

0,

0,

0

FROM users

ON CONFLICT(user_id)

DO NOTHING;
INSERT INTO logs
(
user_id,
action,
ip
)
VALUES

(NULL,'SYSTEM START','127.0.0.1'),
(NULL,'DATABASE CREATED','127.0.0.1');
CREATE INDEX IF NOT EXISTS idx_product_brand
ON products(brand);

CREATE INDEX IF NOT EXISTS idx_product_article
ON products(article);

CREATE INDEX IF NOT EXISTS idx_product_price
ON products(price);

CREATE INDEX IF NOT EXISTS idx_order_created
ON orders(created_at);

CREATE INDEX IF NOT EXISTS idx_logs_created
ON logs(created_at);