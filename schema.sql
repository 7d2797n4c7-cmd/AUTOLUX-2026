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
CREATE TABLE IF NOT EXISTS manufacturers(

    id SERIAL PRIMARY KEY,

    name VARCHAR(100) UNIQUE NOT NULL,

    logo VARCHAR(255)

);
INSERT INTO manufacturers(name,logo) VALUES

('Bosch','bosch.webp'),
('Brembo','brembo.webp'),
('TRW','trw.webp'),
('ATE','ate.webp'),
('Zimmermann','zimmermann.webp'),

('Textar','textar.webp'),
('Ferodo','ferodo.webp'),
('Mahle','mahle.webp'),
('MANN','mann.webp'),
('Filtron','filtron.webp'),

('Purflux','purflux.webp'),
('Sakura','sakura.webp'),
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
('Febi','febi.webp'),
('Meyle','meyle.webp'),

('Mobil','mobil.webp'),
('Liqui Moly','liquimoly.webp'),
('Motul','motul.webp'),
('Shell','shell.webp'),
('Castrol','castrol.webp'),
('Total','total.webp'),
('Elf','elf.webp'),
('Ravenol','ravenol.webp'),
('Idemitsu','idemitsu.webp'),
('ENEOS','eneos.webp'),
('ZIC','zic.webp'),

('Michelin','michelin.webp'),
('Continental','continental.webp'),
('Goodyear','goodyear.webp'),
('Bridgestone','bridgestone.webp'),
('Pirelli','pirelli.webp'),
('Hankook','hankook.webp'),
('Yokohama','yokohama.webp'),

('Varta','varta.webp'),
('Exide','exide.webp'),
('Bosch Battery','bosch_battery.webp'),

('Osram','osram.webp'),
('Philips','philips.webp');
CREATE TABLE IF NOT EXISTS products(

    id SERIAL PRIMARY KEY,

    manufacturer_id INTEGER REFERENCES manufacturers(id),

    category_id INTEGER REFERENCES categories(id),

    brand_id INTEGER REFERENCES car_brands(id),

    model_id INTEGER REFERENCES car_models(id),

    article VARCHAR(50) UNIQUE,

    name VARCHAR(255) NOT NULL,

    description TEXT,

    image TEXT,

    price NUMERIC(12,2) NOT NULL,

    stock INTEGER DEFAULT 0,

    rating NUMERIC(2,1) DEFAULT 5.0,

    reviews INTEGER DEFAULT 0,

    sold INTEGER DEFAULT 0,

    country VARCHAR(100),

    warranty VARCHAR(100),

    weight NUMERIC(8,2),

    is_original BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE IF NOT EXISTS orders(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    total NUMERIC(12,2),

    status VARCHAR(50) DEFAULT 'Новый',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
CREATE TABLE IF NOT EXISTS order_items(

    id SERIAL PRIMARY KEY,

    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,

    product_id INTEGER REFERENCES products(id),

    quantity INTEGER,

    price NUMERIC(12,2)

);
CREATE TABLE IF NOT EXISTS favorites(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,

    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS cart(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,

    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,

    quantity INTEGER DEFAULT 1
);
CREATE TABLE IF NOT EXISTS reviews(

    id SERIAL PRIMARY KEY,

    user_id INTEGER REFERENCES users(id),

    product_id INTEGER REFERENCES products(id),

    rating INTEGER,

    comment TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
('Lexus','lexus.png'),
('Nissan','nissan.png'),
('Infiniti','infiniti.png'),
('Honda','honda.png'),
('Acura','acura.png'),
('Mazda','mazda.png'),
('Subaru','subaru.png'),
('Suzuki','suzuki.png'),
('Mitsubishi','mitsubishi.png'),

('Hyundai','hyundai.png'),
('Kia','kia.png'),
('Genesis','genesis.png'),

('Chevrolet','chevrolet.png'),
('Cadillac','cadillac.png'),
('GMC','gmc.png'),
('Buick','buick.png'),

('Ford','ford.png'),
('Lincoln','lincoln.png'),

('Dodge','dodge.png'),
('Jeep','jeep.png'),
('RAM','ram.png'),
('Chrysler','chrysler.png'),

('Tesla','tesla.png'),

('BMW','bmw.png'),
('Mercedes-Benz','mercedes.png'),
('Audi','audi.png'),
('Volkswagen','volkswagen.png'),
('Porsche','porsche.png'),
('Skoda','skoda.png'),
('Seat','seat.png'),
('Opel','opel.png'),

('Renault','renault.png'),
('Peugeot','peugeot.png'),
('Citroen','citroen.png'),
('Fiat','fiat.png'),
('Alfa Romeo','alfaromeo.png'),

('Volvo','volvo.png'),
('Saab','saab.png'),

('Land Rover','landrover.png'),
('Jaguar','jaguar.png'),
('Mini','mini.png'),

('Bentley','bentley.png'),
('Rolls-Royce','rollsroyce.png'),

('Geely','geely.png'),
('Changan','changan.png'),
('Haval','haval.png'),
('Exeed','exeed.png'),
('Chery','chery.png'),
('Jetour','jetour.png'),
('BYD','byd.png'),
('JAC','jac.png');
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

SELECT id,'M3' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)

SELECT id,'M5' FROM car_brands WHERE name='BMW';

INSERT INTO car_models(brand_id,name)

SELECT id,'XM' FROM car_brands WHERE name='BMW';
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
INSERT INTO car_models(brand_id,name) SELECT id,'911' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'718 Cayman' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'718 Boxster' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Macan' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Cayenne' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Panamera' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Taycan' FROM car_brands WHERE name='Porsche';
INSERT INTO car_models(brand_id,name) SELECT id,'Accent' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Elantra' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Sonata' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Grandeur' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Veloster' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'i20' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'i30' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Kona' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Creta' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Tucson' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Santa Fe' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Palisade' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Staria' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'H-1' FROM car_brands WHERE name='Hyundai';
INSERT INTO car_models(brand_id,name) SELECT id,'Rio' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Cerato' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'K5' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'K8' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Picanto' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Ceed' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Proceed' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Soul' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Seltos' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Sportage' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Sorento' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Mohave' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Carnival' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'EV6' FROM car_brands WHERE name='Kia';
INSERT INTO car_models(brand_id,name) SELECT id,'Micra' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Note' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiida' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Sentra' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Teana' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Altima' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Maxima' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Juke' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Qashqai' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'X-Trail' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Murano' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Patrol' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Navara' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'GT-R' FROM car_brands WHERE name='Nissan';
INSERT INTO car_models(brand_id,name) SELECT id,'Mazda2' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'Mazda3' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'Mazda6' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'CX-3' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'CX-30' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'CX-5' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'CX-7' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'CX-8' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'CX-9' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'MX-5' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'RX-8' FROM car_brands WHERE name='Mazda';
INSERT INTO car_models(brand_id,name) SELECT id,'Civic' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Accord' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'City' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Fit' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Jazz' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Insight' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'CR-Z' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'HR-V' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'CR-V' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Pilot' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Passport' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Ridgeline' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Odyssey' FROM car_brands WHERE name='Honda';
INSERT INTO car_models(brand_id,name) SELECT id,'Lancer' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Galant' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'ASX' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Eclipse Cross' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Outlander' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Pajero' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Pajero Sport' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'L200' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Delica' FROM car_brands WHERE name='Mitsubishi';
INSERT INTO car_models(brand_id,name) SELECT id,'Impreza' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'Legacy' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'WRX' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'BRZ' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'Forester' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'Outback' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'XV' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'Tribeca' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'Levorg' FROM car_brands WHERE name='Subaru';
INSERT INTO car_models(brand_id,name) SELECT id,'Swift' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Baleno' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Ciaz' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'SX4' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Vitara' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Grand Vitara' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Jimny' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Ignis' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Ertiga' FROM car_brands WHERE name='Suzuki';
INSERT INTO car_models(brand_id,name) SELECT id,'Spark' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Aveo' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Cobalt' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Cruze' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Malibu' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Tracker' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Captiva' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Tahoe' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Suburban' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Camaro' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Corvette' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Silverado' FROM car_brands WHERE name='Chevrolet';
INSERT INTO car_models(brand_id,name) SELECT id,'Fiesta' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Focus' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Mondeo' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Fusion' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Escape' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Kuga' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Explorer' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Expedition' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Mustang' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Ranger' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'F-150' FROM car_brands WHERE name='Ford';
INSERT INTO car_models(brand_id,name) SELECT id,'Model S' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Model 3' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Model X' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Model Y' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Cybertruck' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Roadster' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Semi' FROM car_brands WHERE name='Tesla';
INSERT INTO car_models(brand_id,name) SELECT id,'Q30' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'Q50' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'Q60' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'Q70' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'QX30' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'QX50' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'QX55' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'QX60' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'QX80' FROM car_brands WHERE name='Infiniti';
INSERT INTO car_models(brand_id,name) SELECT id,'Emgrand' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Coolray' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Atlas' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Atlas Pro' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Monjaro' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Okavango' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Geometry C' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Tugella' FROM car_brands WHERE name='Geely';
INSERT INTO car_models(brand_id,name) SELECT id,'Arrizo 5' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Arrizo 8' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiggo 2' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiggo 4' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiggo 7 Pro' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiggo 8 Pro' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Tiggo 9' FROM car_brands WHERE name='Chery';
INSERT INTO car_models(brand_id,name) SELECT id,'Jolion' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'M6' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'F7' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'F7x' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'Dargo' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'H6' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'H9' FROM car_brands WHERE name='Haval';
INSERT INTO car_models(brand_id,name) SELECT id,'LX' FROM car_brands WHERE name='Exeed';
INSERT INTO car_models(brand_id,name) SELECT id,'TXL' FROM car_brands WHERE name='Exeed';
INSERT INTO car_models(brand_id,name) SELECT id,'RX' FROM car_brands WHERE name='Exeed';
INSERT INTO car_models(brand_id,name) SELECT id,'VX' FROM car_brands WHERE name='Exeed';
INSERT INTO car_models(brand_id,name) SELECT id,'Alsvin' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'CS35 Plus' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'CS55 Plus' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'CS75 Plus' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'UNI-T' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'UNI-K' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'UNI-V' FROM car_brands WHERE name='Changan';
INSERT INTO car_models(brand_id,name) SELECT id,'Dolphin' FROM car_brands WHERE name='BYD';
INSERT INTO car_models(brand_id,name) SELECT id,'Atto 3' FROM car_brands WHERE name='BYD';
INSERT INTO car_models(brand_id,name) SELECT id,'Seal' FROM car_brands WHERE name='BYD';
INSERT INTO car_models(brand_id,name) SELECT id,'Han' FROM car_brands WHERE name='BYD';
INSERT INTO car_models(brand_id,name) SELECT id,'Tang' FROM car_brands WHERE name='BYD';
INSERT INTO car_models(brand_id,name) SELECT id,'Song Plus' FROM car_brands WHERE name='BYD';
INSERT INTO car_models(brand_id,name) SELECT id,'Yuan Plus' FROM car_brands WHERE name='BYD';
INSERT INTO products (
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
    country,
    warranty,
    is_original
)

SELECT

    1,
    1,
    b.id,
    m.id,

    'ART-' || m.id,

    b.name || ' ' || m.name || ' Масляный фильтр',

    'Оригинальный масляный фильтр для ' || b.name || ' ' || m.name,

    'filter.webp',

    8900,

    15,

    'Германия',

    '12 месяцев',

    TRUE

FROM car_models m
JOIN car_brands b
ON b.id = m.brand_id;
INSERT INTO products(
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

1,
11,
b.id,
m.id,

'OF-'||m.id,

'Bosch Oil Filter '||b.name||' '||m.name,

'Оригинальный масляный фильтр Bosch для '||b.name||' '||m.name,

'bosch_filter.webp',

7900 + (random()*3500)::int,

15 + (random()*30)::int,

ROUND((4+random())::numeric,1),

(random()*200)::int,

(random()*400)::int,

'Германия',

'12 месяцев',

true

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id;
INSERT INTO products(
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

9,
12,
b.id,
m.id,

'AF-'||m.id,

'MANN Air Filter '||b.name||' '||m.name,

'Воздушный фильтр MANN для '||b.name||' '||m.name,

'mann_filter.webp',

8900 + (random()*4000)::int,

20 + (random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*170)::int,

(random()*300)::int,

'Германия',

'12 месяцев',

true

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id;
INSERT INTO products(
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

10,
13,
b.id,
m.id,

'CF-'||m.id,

'Filtron Cabin Filter '||b.name||' '||m.name,

'Салонный фильтр Filtron для '||b.name||' '||m.name,

'cabin_filter.webp',

5900 + (random()*3000)::int,

20 + (random()*30)::int,

ROUND((4+random())::numeric,1),

(random()*150)::int,

(random()*250)::int,

'Польша',

'12 месяцев',

true

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id;
INSERT INTO products(
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

13,
15,
b.id,
m.id,

'SP-'||m.id,

'NGK Spark Plug '||b.name||' '||m.name,

'Свеча зажигания NGK для '||b.name||' '||m.name,

'ngk.webp',

4200 + (random()*1800)::int,

30 + (random()*40)::int,

ROUND((4+random())::numeric,1),

(random()*250)::int,

(random()*500)::int,

'Япония',

'12 месяцев',

true

FROM car_models m
JOIN car_brands b
ON b.id=m.brand_id;
INSERT INTO products(
manufacturer_id,category_id,brand_id,model_id,article,name,description,image,
price,stock,rating,reviews,sold,country,warranty,is_original)

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

4+(random()),

(random()*500)::int,

(random()*1200)::int,

CASE
WHEN mfr.name IN ('Mobil','Motul','Elf','Total','Shell','Castrol') THEN 'Европа'
ELSE 'Германия'
END,

'12 месяцев',

true

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id
CROSS JOIN categories c
CROSS JOIN manufacturers mfr

WHERE c.name='Моторные масла'
AND mfr.name IN
('Mobil','Liqui Moly','Motul','Shell','Castrol','Ravenol','ZIC','ENEOS','Idemitsu');
INSERT INTO products(
manufacturer_id,category_id,brand_id,model_id,article,name,description,image,
price,stock,rating,reviews,sold,country,warranty,is_original)

SELECT

mfr.id,
c.id,
b.id,
m.id,

'BRK-'||m.id||'-'||mfr.id,

mfr.name||' Brake Pads',

'Передние тормозные колодки',

LOWER(REPLACE(mfr.name,' ','_'))||'_pads.webp',

18000+(random()*12000)::int,

10+(random()*30)::int,

4+(random()),

(random()*400)::int,

(random()*1200)::int,

'Германия',

'12 месяцев',

true

FROM car_models m
JOIN car_brands b ON b.id=m.brand_id
CROSS JOIN categories c
CROSS JOIN manufacturers mfr

WHERE c.name='Тормозные колодки'
AND mfr.name IN
('Brembo','ATE','TRW','Textar','Ferodo');
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