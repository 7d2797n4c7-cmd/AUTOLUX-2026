DROP TABLE IF EXISTS logs CASCADE;
DROP TABLE IF EXISTS statistics_daily CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS news_cache CASCADE;
DROP TABLE IF EXISTS vin_requests CASCADE;
DROP TABLE IF EXISTS product_reviews CASCADE;
DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS cart CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS manufacturers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
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
    name VARCHAR(120) UNIQUE NOT NULL,
    image TEXT

);



CREATE TABLE car_models(

    id SERIAL PRIMARY KEY,
    brand_id INTEGER REFERENCES car_brands(id) ON DELETE CASCADE,
    name VARCHAR(120) NOT NULL

);



CREATE TABLE manufacturers(

    id SERIAL PRIMARY KEY,
    name VARCHAR(120) UNIQUE,
    logo TEXT

);



CREATE TABLE categories(

    id SERIAL PRIMARY KEY,
    name VARCHAR(120) UNIQUE

);



CREATE TABLE products(

    id SERIAL PRIMARY KEY,

    manufacturer_id INTEGER REFERENCES manufacturers(id),

    category_id INTEGER REFERENCES categories(id),

    brand_id INTEGER REFERENCES car_brands(id),

    model_id INTEGER REFERENCES car_models(id),

    article VARCHAR(80),

    name TEXT,

    description TEXT,

    image TEXT,

    price NUMERIC(12,2),

    stock INTEGER DEFAULT 0,

    rating NUMERIC(3,1) DEFAULT 5,

    reviews INTEGER DEFAULT 0,

    sold INTEGER DEFAULT 0,

    country VARCHAR(100),

    warranty VARCHAR(100),

    is_original BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);



CREATE TABLE cart(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    product_id INTEGER REFERENCES products(id),

    quantity INTEGER DEFAULT 1

);



CREATE TABLE favorites(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    product_id INTEGER REFERENCES products(id)

);



CREATE TABLE orders(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    total NUMERIC(12,2),

    status VARCHAR(80),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);



CREATE TABLE order_items(

    id SERIAL PRIMARY KEY,

    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,

    product_id INTEGER REFERENCES products(id),

    quantity INTEGER,

    price NUMERIC(12,2)

);



CREATE TABLE product_reviews(

    id SERIAL PRIMARY KEY,

    product_id INTEGER REFERENCES products(id),

    user_id INTEGER REFERENCES users(id),

    rating INTEGER,

    review TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);



CREATE TABLE vin_requests(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    vin VARCHAR(60),

    phone VARCHAR(60),

    comment TEXT,

    answer TEXT,

    status VARCHAR(60),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);



CREATE TABLE promotions(

    id SERIAL PRIMARY KEY,

    title TEXT,

    description TEXT,

    image TEXT,

    discount_percent INTEGER,

    promo_code VARCHAR(40),

    active BOOLEAN DEFAULT TRUE

);



CREATE TABLE news_cache(

    id SERIAL PRIMARY KEY,

    title TEXT,

    description TEXT,

    image TEXT,

    link TEXT,

    source TEXT,

    published TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);



CREATE TABLE statistics_daily(

    id SERIAL PRIMARY KEY,

    stat_date DATE,

    revenue NUMERIC(12,2),

    orders INTEGER,

    new_users INTEGER,

    vin_requests INTEGER

);



CREATE TABLE logs(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    action TEXT,

    ip VARCHAR(60),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
INSERT INTO categories(name) VALUES

('Моторные масла'),
('Трансмиссионные масла'),
('Антифриз'),
('Тормозная жидкость'),
('ГУР'),
('Фильтры масляные'),
('Фильтры воздушные'),
('Фильтры салона'),
('Фильтры топливные'),
('Свечи зажигания'),
('Катушки зажигания'),
('Аккумуляторы'),
('Тормозные колодки'),
('Тормозные диски'),
('Амортизаторы'),
('Стойки'),
('Рычаги'),
('Подшипники'),
('Ремни'),
('Ролики'),
('Помпы'),
('Радиаторы'),
('Кондиционер'),
('Лампочки'),
('Предохранители'),
('Щетки стеклоочистителя'),
('Кузовные детали'),
('Оптика'),
('Сцепление'),
('Аксессуары');
INSERT INTO categories(name)
SELECT 'Жидкость ГУР'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Жидкость ГУР');

INSERT INTO categories(name)
SELECT 'Стойки стабилизатора'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Стойки стабилизатора');

INSERT INTO categories(name)
SELECT 'Шаровые опоры'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Шаровые опоры');

INSERT INTO categories(name)
SELECT 'Рулевые наконечники'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Рулевые наконечники');

INSERT INTO categories(name)
SELECT 'Сайлентблоки'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Сайлентблоки');

INSERT INTO categories(name)
SELECT 'Генераторы'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Генераторы');

INSERT INTO categories(name)
SELECT 'Стартеры'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Стартеры');

INSERT INTO categories(name)
SELECT 'Лампы'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Лампы');

INSERT INTO categories(name)
SELECT 'Бамперы'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Бамперы');

INSERT INTO categories(name)
SELECT 'Капоты'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Капоты');

INSERT INTO categories(name)
SELECT 'Фары'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Фары');

INSERT INTO categories(name)
SELECT 'Фонари'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Фонари');

INSERT INTO categories(name)
SELECT 'Решетки радиатора'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name='Решетки радиатора');
INSERT INTO manufacturers(name,logo) VALUES

('Bosch','bosch.webp'),
('Brembo','brembo.webp'),
('ATE','ate.webp'),
('TRW','trw.webp'),
('Textar','textar.webp'),
('Ferodo','ferodo.webp'),

('Mahle','mahle.webp'),
('MANN','mann.webp'),
('Filtron','filtron.webp'),
('Purflux','purflux.webp'),

('NGK','ngk.webp'),
('Denso','denso.webp'),
('Champion','champion.webp'),

('SKF','skf.webp'),
('SNR','snr.webp'),
('FAG','fag.webp'),
('Timken','timken.webp'),

('KYB','kyb.webp'),
('Sachs','sachs.webp'),
('Bilstein','bilstein.webp'),
('Monroe','monroe.webp'),
('Lemforder','lemforder.webp'),
('Meyle','meyle.webp'),
('Febi','febi.webp'),

('Mobil','mobil.webp'),
('Liqui Moly','liquimoly.webp'),
('Motul','motul.webp'),
('Shell','shell.webp'),
('Castrol','castrol.webp'),
('Elf','elf.webp'),
('Total','total.webp'),
('Ravenol','ravenol.webp'),
('Idemitsu','idemitsu.webp'),
('ENEOS','eneos.webp'),
('ZIC','zic.webp'),

('Michelin','michelin.webp'),
('Continental','continental.webp'),
('Goodyear','goodyear.webp'),
('Bridgestone','bridgestone.webp'),
('Pirelli','pirelli.webp'),
('Yokohama','yokohama.webp'),
('Hankook','hankook.webp'),

('Varta','varta.webp'),
('Exide','exide.webp'),

('Osram','osram.webp'),
('Philips','philips.webp'),

('Valeo','valeo.webp'),
('Dayco','dayco.webp'),
('Gates','gates.webp'),
('INA','ina.webp'),
('LuK','luk.webp'),
('AISIN','aisin.webp');
INSERT INTO car_brands(name,image) VALUES

('Toyota','toyota.webp'),
('Lexus','lexus.webp'),
('Nissan','nissan.webp'),
('Infiniti','infiniti.webp'),
('Honda','honda.webp'),
('Acura','acura.webp'),
('Mazda','mazda.webp'),
('Subaru','subaru.webp'),
('Suzuki','suzuki.webp'),
('Mitsubishi','mitsubishi.webp'),

('Hyundai','hyundai.webp'),
('Kia','kia.webp'),
('Genesis','genesis.webp'),

('BMW','bmw.webp'),
('Mercedes-Benz','mercedes.webp'),
('Audi','audi.webp'),
('Volkswagen','volkswagen.webp'),
('Porsche','porsche.webp'),
('Skoda','skoda.webp'),
('Seat','seat.webp'),
('Opel','opel.webp'),

('Ford','ford.webp'),
('Chevrolet','chevrolet.webp'),
('Cadillac','cadillac.webp'),
('GMC','gmc.webp'),
('Jeep','jeep.webp'),
('Dodge','dodge.webp'),
('RAM','ram.webp'),
('Chrysler','chrysler.webp'),

('Tesla','tesla.webp'),

('Volvo','volvo.webp'),
('Saab','saab.webp'),

('Renault','renault.webp'),
('Peugeot','peugeot.webp'),
('Citroen','citroen.webp'),
('Fiat','fiat.webp'),
('Alfa Romeo','alfaromeo.webp'),

('Bentley','bentley.webp'),
('Rolls-Royce','rollsroyce.webp'),
('Mini','mini.webp'),
('Jaguar','jaguar.webp'),
('Land Rover','landrover.webp'),

('Geely','geely.webp'),
('Changan','changan.webp'),
('Haval','haval.webp'),
('Exeed','exeed.webp'),
('Chery','chery.webp'),
('Jetour','jetour.webp'),
('BYD','byd.webp'),
('JAC','jac.webp'),
('Zeekr','zeekr.webp'),
('Voyah','voyah.webp'),
('Omoda','omoda.webp'),
('Jaecoo','jaecoo.webp'),
('Hongqi','hongqi.webp'),
('Lynk & Co','lynkco.webp');
INSERT INTO manufacturers(name,logo)
SELECT 'Zimmermann','zimmermann.webp'
WHERE NOT EXISTS (SELECT 1 FROM manufacturers WHERE name='Zimmermann');

INSERT INTO manufacturers(name,logo)
SELECT 'Mutlu','mutlu.webp'
WHERE NOT EXISTS (SELECT 1 FROM manufacturers WHERE name='Mutlu');

INSERT INTO manufacturers(name,logo)
SELECT 'OEM','oem.webp'
WHERE NOT EXISTS (SELECT 1 FROM manufacturers WHERE name='OEM');

INSERT INTO manufacturers(name,logo)
SELECT 'CTR','ctr.webp'
WHERE NOT EXISTS (SELECT 1 FROM manufacturers WHERE name='CTR');

INSERT INTO manufacturers(name,logo)
SELECT '555','555.webp'
WHERE NOT EXISTS (SELECT 1 FROM manufacturers WHERE name='555');

INSERT INTO manufacturers(name,logo)
SELECT 'Febest','febest.webp'
WHERE NOT EXISTS (SELECT 1 FROM manufacturers WHERE name='Febest');
/* ---------------- TOYOTA ---------------- */

INSERT INTO car_models(brand_id,name)
SELECT id,'Corolla' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Camry' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Prius' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Yaris' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Corolla Cross' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'C-HR' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'RAV4' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Highlander' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Fortuner' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Hilux' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Land Cruiser Prado' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Land Cruiser 300' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Avalon' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'Supra' FROM car_brands WHERE name='Toyota';

INSERT INTO car_models(brand_id,name)
SELECT id,'GR86' FROM car_brands WHERE name='Toyota';



/* ---------------- LEXUS ---------------- */

INSERT INTO car_models(brand_id,name)
SELECT id,'IS' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'ES' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'GS' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'LS' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'UX' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'NX' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'RX' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'GX' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'LX' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'LC' FROM car_brands WHERE name='Lexus';

INSERT INTO car_models(brand_id,name)
SELECT id,'RC' FROM car_brands WHERE name='Lexus';



/* ---------------- BMW ---------------- */

INSERT INTO car_models(brand_id,name)
SELECT id,'1 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'2 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'3 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'4 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'5 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'6 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'7 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'8 Series' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X1' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X2' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X3' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X4' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X5' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X6' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'X7' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'M2' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'M3' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'M4' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'M5' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)
SELECT id,'XM' FROM car_brands WHERE name='BMW';
/* ---------------- MERCEDES ---------------- */

INSERT INTO car_models(brand_id,name) SELECT id,'A-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'B-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'C-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'CLA' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'CLS' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'E-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'S-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'GLA' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'GLB' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'GLC' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'GLE' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'GLS' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'G-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'AMG GT' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'V-Class' FROM car_brands WHERE name='Mercedes-Benz';
INSERT INTO car_models(brand_id,name) SELECT id,'Sprinter' FROM car_brands WHERE name='Mercedes-Benz';



/* ---------------- AUDI ---------------- */

INSERT INTO car_models(brand_id,name) SELECT id,'A1' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'A3' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'A4' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'A5' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'A6' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'A7' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'A8' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'Q2' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'Q3' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'Q5' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'Q7' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'Q8' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'TT' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'R8' FROM car_brands WHERE name='Audi';
INSERT INTO car_models(brand_id,name) SELECT id,'e-tron' FROM car_brands WHERE name='Audi';



/* ---------------- VOLKSWAGEN ---------------- */

INSERT INTO car_models(brand_id,name) SELECT id,'Polo' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Golf' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Jetta' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Passat' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Arteon' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiguan' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Touareg' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Teramont' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Amarok' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Transporter' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Multivan' FROM car_brands WHERE name='Volkswagen';
INSERT INTO car_models(brand_id,name) SELECT id,'Crafter' FROM car_brands WHERE name='Volkswagen';



/* ---------------- PORSCHE ---------------- */

INSERT INTO car_models(brand_id,name) SELECT id,'911' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'718 Cayman' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'718 Boxster' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Macan' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Cayenne' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Panamera' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Taycan' FROM car_brands WHERE name='Porsche';



/* ---------------- HYUNDAI ---------------- */

INSERT INTO car_models(brand_id,name) SELECT id,'Accent' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Elantra' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Sonata' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Grandeur' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'i20' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'i30' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Kona' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Creta' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Tucson' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Santa Fe' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Palisade' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Staria' FROM car_brands WHERE name='Hyundai';



/* ---------------- KIA ---------------- */

INSERT INTO car_models(brand_id,name) SELECT id,'Rio' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Cerato' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'K5' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Picanto' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Ceed' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Soul' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Seltos' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Sportage' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Sorento' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Carnival' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Mohave' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'EV6' FROM car_brands WHERE name='Kia';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'OIL-'||m.id||'-'||mfr.id,

mfr.name||' 5W-30 Synthetic Oil',

'Полностью синтетическое моторное масло для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'.webp',

19000+(random()*12000)::int,

20+(random()*80)::int,

ROUND((4+random())::numeric,1),

(random()*500)::int,

(random()*1200)::int,

CASE
WHEN mfr.name IN
('Mobil','Motul','Shell','Castrol','Elf','Total')
THEN 'Европа'
ELSE 'Германия'
END,

'12 месяцев',

TRUE

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Mobil',
'Liqui Moly',
'Motul',
'Shell',
'Castrol',
'Elf',
'Total',
'Ravenol',
'Idemitsu',
'ENEOS',
'ZIC'
)

JOIN categories c
ON c.name='Моторные масла';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'OF-'||m.id||'-'||mfr.id,

mfr.name||' Oil Filter',

'Оригинальный масляный фильтр для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_filter.webp',

5900+(random()*3500)::int,

15+(random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*300)::int,

(random()*800)::int,

'Германия',

'12 месяцев',

TRUE

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Bosch',
'Mahle',
'MANN',
'Filtron',
'Purflux'
)

JOIN categories c
ON c.name='Фильтры масляные';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'AF-'||m.id||'-'||mfr.id,

mfr.name||' Air Filter',

'Воздушный фильтр для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_air.webp',

7900+(random()*3000)::int,

15+(random()*30)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*600)::int,

'Германия',

'12 месяцев',

TRUE

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Bosch',
'Mahle',
'MANN',
'Filtron'
)

JOIN categories c
ON c.name='Фильтры воздушные';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'SP-'||m.id||'-'||mfr.id,

mfr.name||' Spark Plug',

'Свеча зажигания для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_spark.webp',

3900+(random()*2500)::int,

20+(random()*80)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*800)::int,

'Япония',

'12 месяцев',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'NGK',
'Denso',
'Bosch',
'Champion'
)

JOIN categories c
ON c.name='Свечи зажигания';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'BP-'||m.id||'-'||mfr.id,

mfr.name||' Brake Pads',

'Комплект тормозных колодок для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_pads.webp',

9900+(random()*9000)::int,

15+(random()*50)::int,

ROUND((4+random())::numeric,1),

(random()*350)::int,

(random()*900)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Brembo',
'ATE',
'TRW',
'Ferodo',
'Textar'
)

JOIN categories c
ON c.name='Тормозные колодки';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'BD-'||m.id||'-'||mfr.id,

mfr.name||' Brake Disc',

'Передний тормозной диск для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_disc.webp',

22000+(random()*15000)::int,

10+(random()*25)::int,

ROUND((4+random())::numeric,1),

(random()*300)::int,

(random()*600)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Brembo',
'ATE',
'Zimmermann',
'TRW'
)

JOIN categories c
ON c.name='Тормозные диски';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'BAT-'||m.id||'-'||mfr.id,

mfr.name||' 70Ah Battery',

'Аккумулятор 70Ah для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_battery.webp',

42000+(random()*25000)::int,

5+(random()*15)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*700)::int,

'Германия',

'36 месяцев',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Bosch',
'Varta',
'Exide',
'Mutlu'
)

JOIN categories c
ON c.name='Аккумуляторы';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'AFR-'||m.id||'-'||mfr.id,

mfr.name||' Antifreeze G12',

'Антифриз G12+ для '||b.name||' '||m.name,

'antifreeze.webp',

7500+(random()*3500)::int,

20+(random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*500)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Liqui Moly',
'Total',
'Motul',
'Shell'
)

JOIN categories c
ON c.name='Антифриз';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'DOT4-'||m.id||'-'||mfr.id,

mfr.name||' DOT-4',

'Тормозная жидкость DOT-4 для '||b.name||' '||m.name,

'brake_fluid.webp',

5200+(random()*2500)::int,

20+(random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*400)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'ATE',
'TRW',
'Bosch',
'Liqui Moly'
)

JOIN categories c
ON c.name='Тормозная жидкость';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'PSF-'||m.id||'-'||mfr.id,

mfr.name||' Power Steering Fluid',

'Жидкость гидроусилителя для '||b.name||' '||m.name,

'power_steering.webp',

6200+(random()*3500)::int,

20+(random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*350)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Liqui Moly',
'Motul',
'Shell'
)

JOIN categories c
ON c.name='Жидкость ГУР';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'SH-'||m.id||'-'||mfr.id,

mfr.name||' Front Shock Absorber',

'Передний амортизатор для '||b.name||' '||m.name,

LOWER(REPLACE(mfr.name,' ','_'))||'_shock.webp',

35000+(random()*20000)::int,

5+(random()*15)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*500)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'KYB',
'Bilstein',
'Sachs',
'Monroe'
)

JOIN categories c
ON c.name='Амортизаторы';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'SL-'||m.id||'-'||mfr.id,

mfr.name||' Stabilizer Link',

'Стойка стабилизатора для '||b.name||' '||m.name,

'stabilizer.webp',

7900+(random()*5000)::int,

15+(random()*30)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*300)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Lemforder',
'CTR',
'555',
'TRW'
)

JOIN categories c
ON c.name='Стойки стабилизатора';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'BJ-'||m.id||'-'||mfr.id,

mfr.name||' Ball Joint',

'Шаровая опора для '||b.name||' '||m.name,

'balljoint.webp',

8500+(random()*5000)::int,

15+(random()*30)::int,

ROUND((4+random())::numeric,1),

(random()*120)::int,

(random()*400)::int,

'Япония',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'555',
'CTR',
'Lemforder'
)

JOIN categories c
ON c.name='Шаровые опоры';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'ARM-'||m.id||'-'||mfr.id,

mfr.name||' Control Arm',

'Передний рычаг подвески для '||b.name||' '||m.name,

'controlarm.webp',

27000+(random()*15000)::int,

10+(random()*20)::int,

ROUND((4+random())::numeric,1),

(random()*120)::int,

(random()*300)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Lemforder',
'Febi',
'TRW',
'Meyle'
)

JOIN categories c
ON c.name='Рычаги';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'TRE-'||m.id||'-'||mfr.id,

mfr.name||' Tie Rod End',

'Рулевой наконечник для '||b.name||' '||m.name,

'tierod.webp',

6900+(random()*4500)::int,

15+(random()*25)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*250)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Lemforder',
'CTR',
'555',
'TRW'
)

JOIN categories c
ON c.name='Рулевые наконечники';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'SB-'||m.id||'-'||mfr.id,

mfr.name||' Silent Block',

'Сайлентблок подвески для '||b.name||' '||m.name,

'silentblock.webp',

4900+(random()*3000)::int,

20+(random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*120)::int,

(random()*350)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Lemforder',
'Febest',
'Febi'
)

JOIN categories c
ON c.name='Сайлентблоки';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'ALT-'||m.id||'-'||mfr.id,

mfr.name||' Alternator',

'Генератор для '||b.name||' '||m.name,

'alternator.webp',

89000+(random()*40000)::int,

5+(random()*10)::int,

ROUND((4+random())::numeric,1),

(random()*120)::int,

(random()*300)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Bosch',
'Denso',
'Valeo'
)

JOIN categories c
ON c.name='Генераторы';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'STR-'||m.id||'-'||mfr.id,

mfr.name||' Starter',

'Стартер для '||b.name||' '||m.name,

'starter.webp',

72000+(random()*35000)::int,

5+(random()*10)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*350)::int,

'Япония',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Denso',
'Bosch',
'Valeo'
)

JOIN categories c
ON c.name='Стартеры';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'IGN-'||m.id||'-'||mfr.id,

mfr.name||' Ignition Coil',

'Катушка зажигания для '||b.name||' '||m.name,

'coil.webp',

16000+(random()*12000)::int,

10+(random()*20)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*600)::int,

'Япония',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Bosch',
'Denso',
'NGK'
)

JOIN categories c
ON c.name='Катушки зажигания';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'LAMP-'||m.id||'-'||mfr.id,

mfr.name||' LED Headlight',

'LED лампы головного света для '||b.name||' '||m.name,

'led.webp',

6900+(random()*9000)::int,

30+(random()*60)::int,

ROUND((4+random())::numeric,1),

(random()*500)::int,

(random()*1200)::int,

'Корея',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Philips',
'Osram',
'Bosch'
)

JOIN categories c
ON c.name='Лампы';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'FUSE-'||m.id||'-'||mfr.id,

mfr.name||' Fuse Set',

'Комплект автомобильных предохранителей для '||b.name||' '||m.name,

'fuse.webp',

1800+(random()*1500)::int,

50+(random()*80)::int,

ROUND((4+random())::numeric,1),

(random()*120)::int,

(random()*800)::int,

'Германия',

'12 месяцев',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name IN
(
'Bosch',
'Valeo'
)

JOIN categories c
ON c.name='Предохранители';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'BMPF-'||m.id,

'Передний бампер',

'Оригинальный передний бампер для '||b.name||' '||m.name,

'front_bumper.webp',

95000+(random()*60000)::int,

5+(random()*10)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*250)::int,

'Китай',

'12 месяцев',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name='OEM'

JOIN categories c
ON c.name='Бамперы';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'HOOD-'||m.id,

'Капот',

'Оригинальный капот для '||b.name||' '||m.name,

'hood.webp',

120000+(random()*80000)::int,

4+(random()*6)::int,

ROUND((4+random())::numeric,1),

(random()*100)::int,

(random()*180)::int,

'Япония',

'12 месяцев',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name='OEM'

JOIN categories c
ON c.name='Капоты';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'HEAD-'||m.id,

'Передняя LED фара',

'Светодиодная фара для '||b.name||' '||m.name,

'headlight.webp',

85000+(random()*70000)::int,

6+(random()*10)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*400)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name='OEM'

JOIN categories c
ON c.name='Фары';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'TAIL-'||m.id,

'Задний фонарь',

'LED фонарь для '||b.name||' '||m.name,

'taillight.webp',

52000+(random()*45000)::int,

5+(random()*8)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*250)::int,

'Германия',

'24 месяца',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name='OEM'

JOIN categories c
ON c.name='Фонари';
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock,
rating,
reviews,
sold,
country,
warranty,
is_original
)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'GRILL-'||m.id,

'Решетка радиатора',

'Передняя решетка радиатора для '||b.name||' '||m.name,

'grille.webp',

22000+(random()*25000)::int,

10+(random()*15)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*300)::int,

'Китай',

'12 месяцев',

TRUE

FROM car_models m

JOIN car_brands b
ON b.id=m.brand_id

JOIN manufacturers mfr
ON mfr.name='OEM'

JOIN categories c
ON c.name='Решетки радиатора';
INSERT INTO car_models(brand_id,name)
SELECT id,'Базовая модель'
FROM car_brands;

INSERT INTO car_models(brand_id,name)
SELECT id,'Premium'
FROM car_brands;

INSERT INTO car_models(brand_id,name)
SELECT id,'Sport'
FROM car_brands;
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock
)

SELECT

1,
1,
brand_id,
id,

'OIL-'||id,

'Моторное масло 5W30',

'Оригинальное моторное масло',

'oil.webp',

19990,

50

FROM car_models;
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock
)

SELECT

2,
6,
brand_id,
id,

'FILTER-'||id,

'Масляный фильтр',

'Оригинальный масляный фильтр',

'filter.webp',

5990,

30

FROM car_models;
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock
)

SELECT

11,
10,
brand_id,
id,

'SPARK-'||id,

'Свеча зажигания',

'Оригинальная свеча',

'spark.webp',

3490,

40

FROM car_models;
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock
)

SELECT

2,
13,
brand_id,
id,

'BRAKE-'||id,

'Тормозные колодки',

'Комплект тормозных колодок',

'brakepads.webp',

11990,

20

FROM car_models;
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock
)

SELECT

26,
3,
brand_id,
id,

'ANTI-'||id,

'Антифриз G12',

'Концентрат G12',

'antifreeze.webp',

6990,

35

FROM car_models;
INSERT INTO products
(
manufacturer_id,
category_id,
brand_id,
model_id,
article,
name,
description,
image,
price,
stock
)

SELECT

43,
12,
brand_id,
id,

'BAT-'||id,

'Аккумулятор 70Ah',

'Автомобильный аккумулятор',

'battery.webp',

45990,

10

FROM car_models;