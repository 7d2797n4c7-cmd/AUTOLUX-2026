from flask import Flask
from flask import render_template
from flask import request
from flask import redirect
from flask import session
from flask import flash
from flask import jsonify
from werkzeug.security import generate_password_hash, check_password_hash

import os
import time
from pathlib import Path

import psycopg2
import feedparser
import requests


app = Flask(__name__)
app.secret_key = "AUTOLUX_SECRET_KEY"

# ---------------- DATABASE ----------------

def db():

    return psycopg2.connect(

        os.getenv("DATABASE_URL"),

        sslmode="require"

    )


def init_database():

    conn = db()
    cur = conn.cursor()

    try:

        cur.execute("""

            SELECT EXISTS(

                SELECT 1

                FROM information_schema.tables

                WHERE table_name='car_brands'

            )

        """)

        exists = cur.fetchone()[0]

        if not exists:

            print("===== DATABASE INIT =====")

            with open("schema.sql", "r", encoding="utf-8") as f:
                schema = f.read()

            cur.execute(schema)

            conn.commit()

            print("===== DATABASE READY =====")

    except Exception as e:

        conn.rollback()
        print("DATABASE INIT ERROR:", e)
        raise

    finally:

        cur.close()
        conn.close()
    

# ---------------- NEWS CACHE ----------------

cached_news = []
last_update = 0

# ---------------- NEWS ----------------

def get_news():

    global cached_news
    global last_update

    if time.time() - last_update < 600:
        return cached_news

    feeds = [
        "https://kolesa.kz/content/news/feed/",
        "https://motor.ru/rss",
        "https://www.zr.ru/rss/news/"
    ]

    news = []

    import re

    for url in feeds:

        try:

            feed = feedparser.parse(url)

            for item in feed.entries[:10]:

                image = "/static/images/default-news.jpg"

                try:

                    if "media_content" in item:
                        image = item.media_content[0]["url"]

                    elif hasattr(item, "summary"):

                        m = re.search(
                            r'<img[^>]+src="([^"]+)"',
                            item.summary
                        )

                        if m:
                            image = m.group(1)

                except:
                    pass

                news.append({

                    "title": item.title,

                    "description": item.summary[:220]
                    if hasattr(item, "summary")
                    else "",

                    "image": image,

                    "link": item.link

                })

        except:
            pass

    cached_news = news
    last_update = time.time()

    return news
# ===========================================
# HOME
# ===========================================

@app.route("/")
def home():

    news = get_news()

    conn = db()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            name,
            image
        FROM car_brands
        ORDER BY name
    """)

    brands = cur.fetchall()

    cur.execute("""
        SELECT
            id,
            title,
            price,
            image,
            brand,
            rating
        FROM products
        ORDER BY sold DESC
        LIMIT 8
    """)

    popular_products = cur.fetchall()

    conn.close()

    return render_template(

        "news.html",

        news=news,

        brands=brands,

        popular_products=popular_products

    )


# ===========================================
# LOGIN
# ===========================================

@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        username = request.form["username"].strip()
        password = request.form["password"]

        # ---------------- ADMIN ----------------

        if username == "admin" and password == "admin":

            session.clear()

            session["admin"] = True
            session["username"] = "Administrator"

            return redirect("/admin")

        conn = db()
        cur = conn.cursor()

        cur.execute(
            """
            SELECT
                id,
                username,
                password
            FROM users
            WHERE username=%s
            """,
            (username,)
        )

        user = cur.fetchone()

        cur.close()
        conn.close()

        if user and check_password_hash(user[2], password):

            session.clear()

            session["user_id"] = user[0]
            session["username"] = user[1]

            flash("Добро пожаловать!", "success")

            return redirect("/profile")

        flash("Неверный логин или пароль", "danger")

    return render_template("login.html")


# ===========================================
# REGISTER
# ===========================================

@app.route("/register", methods=["GET", "POST"])
def register():

    if request.method == "POST":

        username = request.form["username"].strip()
        email = request.form["email"].strip().lower()
        password = request.form["password"]

        conn = db()
        cur = conn.cursor()

        # Проверяем, существует ли пользователь
        cur.execute(
            """
            SELECT id
            FROM users
            WHERE username=%s OR email=%s
            """,
            (username, email)
        )

        if cur.fetchone():

            flash("Пользователь с таким именем или email уже существует", "danger")

            cur.close()
            conn.close()

            return redirect("/register")

        # Хешируем пароль
        password_hash = generate_password_hash(password)

        cur.execute(
            """
            INSERT INTO users
            (
                username,
                email,
                password
            )
            VALUES
            (
                %s,
                %s,
                %s
            )
            """,
            (
                username,
                email,
                password_hash
            )
        )

        conn.commit()

        cur.close()
        conn.close()

        flash("Регистрация успешно завершена!", "success")

        return redirect("/login")

    return render_template("register.html")


# ===========================================
# LOGOUT
# ===========================================

@app.route("/logout")
def logout():

    session.clear()

    flash("Вы вышли из аккаунта", "success")

    return redirect("/")


# ===========================================
# BRANDS
# ===========================================

@app.route("/brands")
def brands():

    conn = db()
    cur = conn.cursor()

    cur.execute("""
        SELECT id,name,image
        FROM car_brands
        ORDER BY name
    """)

    brands = cur.fetchall()

    conn.close()

    return render_template(
        "brands.html",
        brands=brands
    )


# ===========================================
# MODELS
# ===========================================

@app.route("/brand/<int:brand_id>")
def brand_models(brand_id):

    conn = db()
    cur = conn.cursor()

    cur.execute("""

        SELECT name
        FROM car_brands
        WHERE id=%s

    """,(brand_id,))

    brand_name = cur.fetchone()[0]

    cur.execute("""

        SELECT
            id,
            name

        FROM car_models

        WHERE brand_id=%s

        ORDER BY name

    """,(brand_id,))

    models = cur.fetchall()

    conn.close()

    return render_template(

        "models.html",

        models=models,

        brand_name=brand_name

    )
    # ===========================================
# CATALOG
# ===========================================

@app.route("/catalog/<int:model_id>")
def catalog(model_id):

    conn = db()
    cur = conn.cursor()

    cur.execute("""
        SELECT name
        FROM car_models
        WHERE id=%s
    """,(model_id,))

    model_name = cur.fetchone()[0]

    search = request.args.get("q","")

    if search:

        cur.execute("""
        SELECT
            id,
            title,
            description,
            image,
            price,
            stock,
            rating,
            brand
        FROM products
        WHERE model_id=%s
        AND LOWER(title) LIKE LOWER(%s)
        ORDER BY title
        """,(model_id,"%"+search+"%"))

    else:

        cur.execute("""
        SELECT
            id,
            title,
            description,
            image,
            price,
            stock,
            rating,
            brand
        FROM products
        WHERE model_id=%s
        ORDER BY title
        """,(model_id,))

    products = cur.fetchall()

    conn.close()

    return render_template(
        "catalog.html",
        products=products,
        model_name=model_name
    )


# ===========================================
# PRODUCT
# ===========================================

products = cur.fetchall()

conn.close()

return render_template(
    "catalog.html",
    products=products,
    model_name=model_name
)

@app.route("/product/<int:product_id>")
def product(product_id):

    conn = db()
    cur = conn.cursor()

    # Получаем товар

    cur.execute("""

        SELECT

            id,
            title,
            description,
            image,
            price,
            stock,
            rating,
            brand

        FROM products

        WHERE id=%s

    """,(product_id,))

    product = cur.fetchone()

    if not product:

        conn.close()

        return "Товар не найден",404

    # Похожие товары

    cur.execute("""

        SELECT

            id,
            title,
            image,
            price,
            rating

        FROM products

        WHERE id<>%s

        LIMIT 4

    """,(product_id,))

    related = cur.fetchall()

    conn.close()

    return render_template(

        "product.html",

        product=product,

        related=related

    )
    
# ===========================================
# CART
# ===========================================

@app.route("/cart")
def cart():

    if "user_id" not in session:
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT

        cart.id,
        products.id,
        products.name,
        products.image,
        products.price,
        cart.qty

    FROM cart

    JOIN products
    ON products.id=cart.product_id

    WHERE cart.username=%s

    """,(session["username"],))

    items=cur.fetchall()

    total=0

    for item in items:

        total+=item[4]*item[5]

    conn.close()

    return render_template(

        "cart.html",

        items=items,

        total=total

    )

# ===========================================
# ADD TO CART
# ===========================================

@app.route("/cart/add/<int:id>")
def add_to_cart(id):

    if "user_id" not in session:
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT id

    FROM cart

    WHERE username=%s

    AND product_id=%s

    """,(session["username"],id))

    item=cur.fetchone()

    if item:

        cur.execute("""

        UPDATE cart

        SET qty=qty+1

        WHERE id=%s

        """,(item[0],))

    else:

        cur.execute("""

        INSERT INTO cart
        (
        username,
        product_id,
        qty
        )

        VALUES
        (
        %s,
        %s,
        1
        )

        """,(session["username"],id))

    conn.commit()
    conn.close()

    return redirect("/cart")


# ===========================================
# REMOVE CART
# ===========================================

@app.route("/cart/remove/<int:id>")
def remove_cart(id):

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    DELETE FROM cart

    WHERE id=%s

    """,(id,))

    conn.commit()
    conn.close()

    return redirect("/cart")


    # ===========================================
# PROFILE
# ===========================================

@app.route("/profile")
def profile():

    if "user_id" not in session:
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT

        username,
        email,
        phone,
        avatar,
        created_at

    FROM users

    WHERE id=%s

    """,(session["user_id"],))

    user=cur.fetchone()

    cur.execute("""

    SELECT

        id,
        total_price,
        created_at

    FROM orders

    WHERE user_id=%s

    ORDER BY id DESC

    """,(session["user_id"],))

    orders=cur.fetchall()

    conn.close()

    return render_template(

        "profile.html",

        user=user,

        orders=orders

    )

# ===========================================
# ORDER DETAILS
# ===========================================

@app.route("/order/<int:order_id>")
def order_details(order_id):

    if "user_id" not in session:
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        SELECT

            orders.id,

            orders.full_name,

            orders.phone,

            orders.address,

            orders.comment,

            orders.total_price,

            orders.created_at,

            order_statuses.name,

            order_statuses.color

        FROM orders

        JOIN order_statuses

        ON order_statuses.id=orders.status_id

        WHERE orders.id=%s

        AND orders.user_id=%s

    """,(

        order_id,

        session["user_id"]

    ))

    order = cur.fetchone()

    cur.execute("""

        SELECT

            products.title,

            products.image,

            order_items.quantity,

            order_items.price

        FROM order_items

        JOIN products

        ON products.id=order_items.product_id

        WHERE order_items.order_id=%s

    """,(

        order_id,

    ))

    items = cur.fetchall()

    conn.close()

    return render_template(

        "order.html",

        order=order,

        items=items

    )


# ===========================================
# VIN REQUEST
# ===========================================

@app.route("/vin",methods=["GET","POST"])
def vin():

    if request.method=="POST":

        conn=db()
        cur=conn.cursor()

        cur.execute("""

            INSERT INTO vin_requests(

                user_id,

                vin,

                phone,

                comment,

                status

            )

            VALUES(

                %s,%s,%s,%s,

                'Новая'

            )

        """,(

            session.get("user_id"),

            request.form["vin"],

            request.form["phone"],

            request.form["comment"]

        ))

        conn.commit()

        conn.close()

        flash("VIN успешно отправлен")

        return redirect("/profile")

    return render_template("vin.html")


# ===========================================
# PROMOTIONS
# ===========================================

@app.route("/promotions")
def promotions():

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT

        title,

        description,

        image,

        discount_percent,

        promo_code,

        date_end

    FROM promotions

    WHERE active=true

    ORDER BY date_end

    """)

    promotions=[]

    for row in cur.fetchall():

        promotions.append({

            "title":row[0],

            "description":row[1],

            "image":row[2],

            "discount":row[3],

            "code":row[4],

            "end":row[5]

        })

    conn.close()

    return render_template(

        "promotions.html",

        promotions=promotions

    )


# ===========================================
# PAYMENT SUCCESS
# ===========================================

@app.route("/payment-success")
def payment_success():

    return render_template("payment_success.html")


# ===========================================
# PAYMENT CANCEL
# ===========================================

@app.route("/payment-cancel")
def payment_cancel():

    return render_template("payment_cancel.html")
# ===========================================
# ADMIN DASHBOARD
# ===========================================

@app.route("/admin")
def admin():

    if not session.get("admin"):
        return redirect("/login")

    conn = db()
    cur = conn.cursor()

    # Пользователи
    cur.execute("SELECT COUNT(*) FROM users")
    users_count = cur.fetchone()[0]

    # Заказы
    cur.execute("SELECT COUNT(*) FROM orders")
    orders_count = cur.fetchone()[0]

    # Выручка
    cur.execute("""
        SELECT COALESCE(SUM(total_price),0)
        FROM orders
    """)
    revenue = cur.fetchone()[0]

    # За сегодня
    cur.execute("""
        SELECT COALESCE(SUM(total_price),0)
        FROM orders
        WHERE DATE(created_at)=CURRENT_DATE
    """)
    today_revenue = cur.fetchone()[0]

    # Топ товары
    cur.execute("""
        SELECT
            title,
            sold
        FROM products
        ORDER BY sold DESC
        LIMIT 10
    """)

    top_products = cur.fetchall()

    # Последние заказы
    cur.execute("""
        SELECT

            orders.id,
            users.username,
            orders.total_price,
            order_statuses.name,
            orders.created_at

        FROM orders

        JOIN users
        ON users.id=orders.user_id

        JOIN order_statuses
        ON order_statuses.id=orders.status_id

        ORDER BY orders.id DESC

        LIMIT 15
    """)

    last_orders = cur.fetchall()

    conn.close()

    return render_template(

        "admin.html",

        users_count=users_count,

        orders_count=orders_count,

        revenue=revenue,

        today_revenue=today_revenue,

        top_products=top_products,

        last_orders=last_orders

    )


# ===========================================
# ADMIN ORDERS
# ===========================================

@app.route("/admin/orders")
def admin_orders():

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    search=request.args.get("search","")

    if search:

        cur.execute("""

        SELECT

            orders.id,

            orders.full_name,

            orders.phone,

            delivery_cities.name,

            orders.total_price,

            order_statuses.name,

            order_statuses.color,

            orders.created_at

        FROM orders

        JOIN order_statuses

        ON order_statuses.id=orders.status_id

        JOIN delivery_cities

        ON delivery_cities.id=orders.city_id

        WHERE

            LOWER(orders.full_name) LIKE LOWER(%s)

            OR

            orders.phone LIKE %s

        ORDER BY orders.id DESC

        """,(

            "%"+search+"%",

            "%"+search+"%"

        ))

    else:

        cur.execute("""

        SELECT

            orders.id,

            orders.full_name,

            orders.phone,

            delivery_cities.name,

            orders.total_price,

            order_statuses.name,

            order_statuses.color,

            orders.created_at

        FROM orders

        JOIN order_statuses

        ON order_statuses.id=orders.status_id

        JOIN delivery_cities

        ON delivery_cities.id=orders.city_id

        ORDER BY orders.id DESC

        """)

    rows=cur.fetchall()

    orders=[]

    for r in rows:

        orders.append({

            "id":r[0],

            "full_name":r[1],

            "phone":r[2],

            "city":r[3],

            "total_price":r[4],

            "status":r[5],

            "color":r[6],

            "created_at":r[7]

        })

    conn.close()

    return render_template(

        "admin_orders.html",

        orders=orders

    )


# ===========================================
# CHANGE STATUS
# ===========================================

@app.route("/admin/change-status/<int:id>",methods=["POST"])
def change_status(id):

    if not session.get("admin"):
        return redirect("/login")

    status=request.form["status"]

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        UPDATE orders

        SET status_id=%s

        WHERE id=%s

    """,(

        status,
        id

    ))

    conn.commit()
    conn.close()

    return redirect("/admin/orders")


# ===========================================
# CUSTOMERS
# ===========================================

@app.route("/admin/customers")
def admin_customers():

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    search=request.args.get("search","")

    if search:

        cur.execute("""

        SELECT

            users.id,
            users.username,
            users.email,
            users.phone,

            COALESCE(customer_stats.total_orders,0),

            COALESCE(customer_stats.total_spent,0),

            COALESCE(customer_stats.average_check,0)

        FROM users

        LEFT JOIN customer_stats

        ON users.id=customer_stats.user_id

        WHERE

            LOWER(users.username)

            LIKE LOWER(%s)

        ORDER BY users.id

        """,("%"+search+"%",))

    else:

        cur.execute("""

        SELECT

            users.id,
            users.username,
            users.email,
            users.phone,

            COALESCE(customer_stats.total_orders,0),

            COALESCE(customer_stats.total_spent,0),

            COALESCE(customer_stats.average_check,0)

        FROM users

        LEFT JOIN customer_stats

        ON users.id=customer_stats.user_id

        ORDER BY users.id

        """)

    rows=cur.fetchall()

    customers=[]

    for r in rows:

        customers.append({

            "id":r[0],

            "username":r[1],

            "email":r[2],

            "phone":r[3],

            "orders":r[4],

            "total":r[5],

            "average":r[6]

        })

    conn.close()

    return render_template(

        "admin_customers.html",

        customers=customers

    )
    
    
@app.route("/admin/customer/<int:user_id>")
def admin_customer(user_id):

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT

        users.username,

        COALESCE(customer_stats.total_orders,0),

        COALESCE(customer_stats.total_spent,0),

        COALESCE(customer_stats.average_check,0)

    FROM users

    LEFT JOIN customer_stats

    ON users.id=customer_stats.user_id

    WHERE users.id=%s

    """,(user_id,))

    r=cur.fetchone()

    customer={

        "username":r[0],

        "orders":r[1],

        "total":r[2],

        "average":r[3]

    }

    cur.execute("""

    SELECT

        id,

        created_at,

        total_price

    FROM orders

    WHERE user_id=%s

    ORDER BY id DESC

    """,(user_id,))

    orders=cur.fetchall()

    conn.close()

    return render_template(

        "admin_customer.html",

        customer=customer,

        orders=orders

    )


# ===========================================
# STATISTICS
# ===========================================

@app.route("/admin/statistics")
def admin_statistics():

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("SELECT COUNT(*) FROM users")
    users_count=cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM orders")
    orders_count=cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM car_brands")
    brands_count=cur.fetchone()[0]

    cur.execute("""

    SELECT
    COALESCE(SUM(total_price),0)

    FROM orders

    """)

    revenue=cur.fetchone()[0]

    cur.execute("""

    SELECT

        title,

        sold

    FROM products

    ORDER BY sold DESC

    LIMIT 10

    """)

    rows=cur.fetchall()

    top_products=[]

    for r in rows:

        top_products.append({

            "title":r[0],

            "sold":r[1]

        })

    cur.execute("""

    SELECT

        brand,

        SUM(sold)

    FROM products

    GROUP BY brand

    ORDER BY SUM(sold) DESC

    LIMIT 10

    """)

    rows=cur.fetchall()

    brands=[]

    for r in rows:

        brands.append({

            "brand":r[0],

            "count":r[1]

        })

    cur.execute("""

    SELECT

        car_models.name,

        SUM(products.sold)

    FROM products

    JOIN car_models

    ON car_models.id=products.model_id

    GROUP BY car_models.name

    ORDER BY SUM(products.sold) DESC

    LIMIT 10

    """)

    rows=cur.fetchall()

    models=[]

    for r in rows:

        models.append({

            "model":r[0],

            "count":r[1]

        })

    conn.close()

    return render_template(

        "admin_statistics.html",

        revenue=revenue,

        users_count=users_count,

        orders_count=orders_count,

        brands_count=brands_count,

        top_products=top_products,

        brands=brands,

        models=models

    )


# ===========================================
# VIN REQUESTS
# ===========================================

@app.route("/admin/vin")
def admin_vin():

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        SELECT

            vin_requests.id,

            users.username,

            vin,

            phone,

            status,

            created_at

        FROM vin_requests

        LEFT JOIN users

        ON users.id=vin_requests.user_id

        ORDER BY id DESC

    """)

    requests=cur.fetchall()

    conn.close()

    return render_template(

        "admin_vin.html",

        requests=requests

    )


# ===========================================
# PROMOTIONS
# ===========================================

@app.route("/admin/promotions")
def admin_promotions():

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        SELECT *

        FROM promotions

        ORDER BY id DESC

    """)

    promotions=cur.fetchall()

    conn.close()

    return render_template(

        "admin_promotions.html",

        promotions=promotions

    )


# ===========================================
# LOGS
# ===========================================

@app.route("/admin/logs")
def admin_logs():

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        SELECT *

        FROM logs

        ORDER BY id DESC

        LIMIT 300

    """)

    logs=cur.fetchall()

    conn.close()

    return render_template(

        "admin_logs.html",

        logs=logs

    )
    
    
@app.route("/checkout", methods=["GET","POST"])
def checkout():

    if "user_id" not in session:
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    if request.method=="POST":

        fullname=request.form["fullname"]
        phone=request.form["phone"]
        city=request.form["city"]
        address=request.form["address"]
        comment=request.form["comment"]
        payment=request.form["payment"]

        cur.execute("""

        SELECT

            cart.product_id,
            cart.qty,
            products.price

        FROM cart

        JOIN products

        ON products.id=cart.product_id

        WHERE cart.username=%s

        """,(session["username"],))

        items=cur.fetchall()

        total=0

        for item in items:

            total+=item[1]*item[2]

        cur.execute("""

        INSERT INTO orders
        (

            user_id,
            full_name,
            phone,
            address,
            comment,
            total_price

        )

        VALUES
        (
            %s,
            %s,
            %s,
            %s,
            %s,
            %s
        )

        RETURNING id

        """,(

            session["user_id"],
            fullname,
            phone,
            address,
            comment,
            total

        ))

        order_id=cur.fetchone()[0]

        for item in items:

            cur.execute("""

            INSERT INTO order_items
            (

                order_id,
                product_id,
                quantity,
                price

            )

            VALUES
            (

                %s,
                %s,
                %s,
                %s

            )

            """,(

                order_id,
                item[0],
                item[1],
                item[2]

            ))

        cur.execute("""

        DELETE FROM cart

        WHERE username=%s

        """,(session["username"],))

        conn.commit()

        flash("Заказ успешно оформлен!")

        conn.close()

        return redirect("/profile")

    conn.close()

    return render_template("checkout.html")
    
    
@app.route("/admin/order/<int:order_id>")
def admin_order(order_id):

    if not session.get("admin"):
        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT

        orders.id,
        orders.status_id,
        orders.full_name,
        orders.phone,
        orders.address,
        delivery_cities.name,
        payment_methods.name,
        orders.total_price,
        orders.created_at

    FROM orders

    JOIN delivery_cities

    ON delivery_cities.id=orders.city_id

    JOIN payment_methods

    ON payment_methods.id=orders.payment_method_id

    WHERE orders.id=%s

    """,(order_id,))

    r=cur.fetchone()

    order={

        "id":r[0],
        "status_id":r[1],
        "full_name":r[2],
        "phone":r[3],
        "address":r[4],
        "city":r[5],
        "payment":r[6],
        "total_price":r[7],
        "created_at":r[8]

    }

    cur.execute("""

    SELECT

        products.title,
        order_items.quantity,
        order_items.price

    FROM order_items

    JOIN products

    ON products.id=order_items.product_id

    WHERE order_items.order_id=%s

    """,(order_id,))

    rows=cur.fetchall()

    items=[]

    for row in rows:

        items.append({

            "title":row[0],
            "quantity":row[1],
            "price":row[2],
            "total":row[1]*row[2]

        })

    cur.execute("""

    SELECT

        id,
        name

    FROM order_statuses

    ORDER BY id

    """)

    statuses=cur.fetchall()

    conn.close()

    return render_template(

        "admin_order.html",

        order=order,

        items=items,

        statuses=statuses

    )
    
    
@app.route("/admin/order/<int:order_id>/status", methods=["POST"])
def admin_change_status(order_id):

    if not session.get("admin"):
        return redirect("/login")

    status=request.form["status_id"]

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    UPDATE orders

    SET status_id=%s

    WHERE id=%s

    """,(status,order_id))

    conn.commit()

    conn.close()

    return redirect(f"/admin/order/{order_id}")

# ===========================================
# RUN
# ===========================================

def execute_if_not_exists(check_sql, insert_sql):

    conn = db()
    cur = conn.cursor()

    cur.execute(check_sql)
    exists = cur.fetchone()[0]

    if not exists:
        print("Добавляю новые данные...")
        cur.execute(insert_sql)
        conn.commit()

    cur.close()
    conn.close()


def update_database():

    execute_if_not_exists(

        "SELECT EXISTS(SELECT 1 FROM car_brands WHERE name='Tesla')",

        """

        INSERT INTO car_brands(name,image) VALUES
        ('Tesla','tesla.webp'),
        ('BYD','byd.webp'),
        ('Zeekr','zeekr.webp'),
        ('Voyah','voyah.webp'),
        ('Omoda','omoda.webp'),
        ('Jaecoo','jaecoo.webp'),
        ('Jetour','jetour.webp'),
        ('Exeed','exeed.webp');

        """

    )


init_database()
update_database()


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 5000))
    )