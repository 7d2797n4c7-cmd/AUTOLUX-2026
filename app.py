from flask import Flask
from flask import render_template
from flask import request
from flask import redirect
from flask import session
from flask import flash
from flask import jsonify

import psycopg2
import feedparser
import requests
import os
import time

app = Flask(__name__)
app.secret_key = "AUTOLUX_SECRET_KEY"

# ---------------- DATABASE ----------------

def db():
    return psycopg2.connect(
        os.environ["DATABASE_URL"]
    )

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

@app.route("/login", methods=["GET","POST"])
def login():

    if request.method=="POST":

        username=request.form["username"]
        password=request.form["password"]

        # ---------------- ADMIN ----------------

        if username=="admin" and password=="admin":

            session.clear()

            session["admin"]=True
            session["username"]="Administrator"

            return redirect("/admin")

        conn=db()
        cur=conn.cursor()

        cur.execute("""

            SELECT

                id,
                username

            FROM users

            WHERE username=%s
            AND password=%s

        """,(

            username,
            password

        ))

        user=cur.fetchone()

        conn.close()

        if user:

            session["user_id"]=user[0]
            session["username"]=user[1]

            return redirect("/profile")

        flash("Неверный логин или пароль")

    return render_template("login.html")


# ===========================================
# REGISTER
# ===========================================

@app.route("/register", methods=["GET","POST"])
def register():

    if request.method=="POST":

        username=request.form["username"]
        email=request.form["email"]
        password=request.form["password"]

        conn=db()
        cur=conn.cursor()

        cur.execute("""

            INSERT INTO users(

                username,
                email,
                password

            )

            VALUES(

                %s,%s,%s

            )

        """,(

            username,
            email,
            password

        ))

        conn.commit()
        conn.close()

        flash("Аккаунт успешно создан")

        return redirect("/login")

    return render_template("register.html")


# ===========================================
# LOGOUT
# ===========================================

@app.route("/logout")
def logout():

    session.clear()

    return redirect("/")


# ===========================================
# BRANDS
# ===========================================

@app.route("/brands")
def brands():

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        SELECT

            id,
            name,
            image

        FROM car_brands

        ORDER BY name

    """)

    brands=cur.fetchall()

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

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        SELECT name

        FROM car_models

        WHERE id=%s

    """,(model_id,))

    model_name=cur.fetchone()[0]

    search=request.args.get("q","")

    if search:

        cur.execute("""

            SELECT *

            FROM products

            WHERE model_id=%s

            AND LOWER(title) LIKE LOWER(%s)

            ORDER BY title

        """,(model_id,"%"+search+"%"))

    else:

        cur.execute("""

            SELECT *

            FROM products

            WHERE model_id=%s

            ORDER BY title

        """,(model_id,))

    products=cur.fetchall()

    conn.close()

    return render_template(

        "catalog.html",

        products=products,

        model_name=model_name

    )


# ===========================================
# PRODUCT
# ===========================================

@app.route("/product/<int:product_id>")
def product(product_id):

    conn=db()
    cur=conn.cursor()

    cur.execute("""

        UPDATE products

        SET views=views+1

        WHERE id=%s

    """,(product_id,))

    conn.commit()

    cur.execute("""

        SELECT *

        FROM products

        WHERE id=%s

    """,(product_id,))

    row=cur.fetchone()

    if not row:

        conn.close()

        return redirect("/")

    product={

        "id":row[0],
        "model_id":row[1],
        "category_id":row[2],
        "title":row[3],
        "description":row[4],
        "brand":row[5],
        "article":row[6],
        "image":row[7],
        "price":row[8],
        "stock":row[9],
        "sold":row[10],
        "views":row[11],
        "rating":row[12]

    }

    cur.execute("""

        SELECT *

        FROM products

        WHERE model_id=%s

        AND id<>%s

        LIMIT 4

    """,(product["model_id"],product_id))

    rows=cur.fetchall()

    similar=[]

    for r in rows:

        similar.append({

            "id":r[0],
            "title":r[3],
            "image":r[7],
            "price":r[8]

        })

    cur.execute("""

        SELECT

            users.username,

            rating,

            review

        FROM product_reviews

        JOIN users

        ON users.id=product_reviews.user_id

        WHERE product_id=%s

        ORDER BY created_at DESC

    """,(product_id,))

    reviews=[]

    for r in cur.fetchall():

        reviews.append({

            "username":r[0],
            "rating":r[1],
            "review":r[2]

        })

    conn.close()

    return render_template(

        "product.html",

        product=product,

        similar=similar,

        reviews=reviews

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

        products.title,

        products.image,

        products.brand,

        products.price,

        cart.qty

    FROM cart

    JOIN products

    ON products.id=cart.product_id

    WHERE cart.username=%s

    """,(session["username"],))

    rows=cur.fetchall()

    cart=[]

    total=0

    count=0

    for r in rows:

        s=r[4]*r[5]

        total+=s
        count+=r[5]

        cart.append({

            "id":r[0],

            "title":r[1],

            "image":r[2],

            "brand":r[3],

            "price":r[4],

            "qty":r[5],

            "total":s

        })

    conn.close()

    return render_template(

        "cart.html",

        cart=cart,

        total=total,

        count=count

    )

# ===========================================
# ADD TO CART
# ===========================================

@app.route("/cart/add/<int:id>")
def add_cart(id):

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

    row=cur.fetchone()

    if row:

        cur.execute("""

        UPDATE cart

        SET qty=qty+1

        WHERE id=%s

        """,(row[0],))

    else:

        cur.execute("""

        INSERT INTO cart(

        username,

        product_id,

        qty

        )

        VALUES(%s,%s,1)

        """,(session["username"],id))

    conn.commit()

    conn.close()

    return redirect("/cart")


# ===========================================
# REMOVE CART
# ===========================================

@app.route("/remove-cart/<int:id>")
def remove_cart(id):

    if "user_id" not in session:
        return redirect("/login")

    conn = db()
    cur = conn.cursor()

    cur.execute("""

        DELETE FROM cart

        WHERE id=%s

    """, (

        id,

    ))

    conn.commit()
    conn.close()

    return redirect("/cart")


# ===========================================
# BUY
# ===========================================

@app.route("/buy", methods=["GET","POST"])
def buy():

    if "user_id" not in session:
        return redirect("/login")

    conn = db()
    cur = conn.cursor()

    cur.execute("""

        SELECT

            cart.product_id,
            cart.qty,
            products.price

        FROM cart

        JOIN products
        ON products.id = cart.product_id

        WHERE cart.username=%s

    """, (

        session["username"],

    ))

    cart_items = cur.fetchall()

    cur.execute("""

        SELECT *

        FROM delivery_cities

        ORDER BY name

    """)

    cities = cur.fetchall()

    cur.execute("""

        SELECT *

        FROM payment_methods

        ORDER BY id

    """)

    payments = cur.fetchall()

    if request.method == "POST":

        city = request.form["city"]
        payment = request.form["payment"]
        fullname = request.form["fullname"]
        phone = request.form["phone"]
        address = request.form["address"]
        comment = request.form["comment"]

        total = 0

        for row in cart_items:
            total += row[1] * row[2]

        cur.execute("""

            SELECT delivery_price

            FROM delivery_cities

            WHERE id=%s

        """, (

            city,

        ))

        delivery = cur.fetchone()[0]

        total += delivery

        cur.execute("""

            INSERT INTO orders(

                user_id,
                status_id,
                city_id,
                payment_method_id,
                full_name,
                phone,
                address,
                comment,
                total_price

            )

            VALUES(

                %s,1,%s,%s,%s,%s,%s,%s,%s

            )

            RETURNING id

        """, (

            session["user_id"],
            city,
            payment,
            fullname,
            phone,
            address,
            comment,
            total

        ))

        order_id = cur.fetchone()[0]

        for row in cart_items:

            cur.execute("""

                INSERT INTO order_items(

                    order_id,
                    product_id,
                    quantity,
                    price

                )

                VALUES(

                    %s,%s,%s,%s

                )

            """, (

                order_id,
                row[0],
                row[1],
                row[2]

            ))

            cur.execute("""

                UPDATE products

                SET

                    sold = sold + %s,

                    stock = stock - %s

                WHERE id=%s

            """, (

                row[1],
                row[1],
                row[0]

            ))

        cur.execute("""

            DELETE FROM cart

            WHERE username=%s

        """, (

            session["username"],

        ))

        conn.commit()
        conn.close()

        return redirect("/payment-success")

    conn.close()

    return render_template(

        "buy.html",

        cities=cities,

        payments=payments,

        cart_items=cart_items

    )
    # ===========================================
# PROFILE
# ===========================================

@app.route("/profile")
def profile():

    if "user_id" not in session:
        return redirect("/login")

    conn = db()
    cur = conn.cursor()

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

    user = cur.fetchone()

    cur.execute("""
        SELECT

            orders.id,
            order_statuses.name,
            order_statuses.color,
            orders.total_price,
            orders.created_at

        FROM orders

        JOIN order_statuses
        ON order_statuses.id = orders.status_id

        WHERE orders.user_id=%s

        ORDER BY orders.created_at DESC
    """,(session["user_id"],))

    orders = cur.fetchall()

    cur.execute("""
        SELECT
            COUNT(*),
            COALESCE(SUM(total_price),0)
        FROM orders
        WHERE user_id=%s
    """,(session["user_id"],))

    stats = cur.fetchone()

    conn.close()

    return render_template(

        "profile.html",

        user=user,

        orders=orders,

        stats=stats

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

        city=request.form["city"]
        payment=request.form["payment"]

        full_name=request.form["full_name"]
        phone=request.form["phone"]
        address=request.form["address"]
        comment=request.form["comment"]

        cur.execute("""

        SELECT

        cart.product_id,
        cart.qty,
        products.price

        FROM cart

        JOIN products

        ON products.id=cart.product_id

        WHERE username=%s

        """,(session["username"],))

        items=cur.fetchall()

        total=0

        for item in items:

            total+=item[1]*item[2]

        cur.execute("""

        INSERT INTO orders(

        user_id,

        status_id,

        city_id,

        payment_method_id,

        full_name,

        phone,

        address,

        comment,

        total_price

        )

        VALUES(

        %s,1,%s,%s,%s,%s,%s,%s,%s

        )

        RETURNING id

        """,(

        session["user_id"],

        city,

        payment,

        full_name,

        phone,

        address,

        comment,

        total

        ))

        order_id=cur.fetchone()[0]

        for item in items:

            cur.execute("""

            INSERT INTO order_items(

            order_id,

            product_id,

            quantity,

            price

            )

            VALUES(%s,%s,%s,%s)

            """,(

            order_id,

            item[0],

            item[1],

            item[2]

            ))

            cur.execute("""

            UPDATE products

            SET

            sold=sold+%s,

            stock=stock-%s

            WHERE id=%s

            """,(

            item[1],

            item[1],

            item[0]

            ))

        cur.execute("""

        DELETE FROM cart

        WHERE username=%s

        """,(session["username"],))

        conn.commit()

        conn.close()

        return redirect("/profile")

    cur.execute("""

    SELECT

    id,
    name,
    delivery_price

    FROM delivery_cities

    ORDER BY name

    """)

    cities=cur.fetchall()

    cur.execute("""

    SELECT

    id,
    name

    FROM payment_methods

    """)

    payments=cur.fetchall()

    cur.execute("""

    SELECT

    SUM(products.price*cart.qty),

    SUM(cart.qty)

    FROM cart

    JOIN products

    ON products.id=cart.product_id

    WHERE username=%s

    """,(session["username"],))

    row=cur.fetchone()

    total=row[0] or 0
    count=row[1] or 0

    conn.close()

    return render_template(

    "checkout.html",

    cities=cities,

    payments=payments,

    total=total,

    count=count

    )
    
@app.route("/order/<int:order_id>")
def order(order_id):

    if "user_id" not in session:

        return redirect("/login")

    conn=db()
    cur=conn.cursor()

    cur.execute("""

    SELECT

        orders.id,

        order_statuses.name,

        orders.total_price,

        orders.created_at,

        orders.address,

        orders.phone,

        orders.comment

    FROM orders

    JOIN order_statuses

    ON order_statuses.id=orders.status_id

    WHERE

        orders.id=%s

    AND

        user_id=%s

    """,(order_id,session["user_id"]))

    order=cur.fetchone()

    cur.execute("""

    SELECT

        products.title,

        order_items.quantity,

        order_items.price

    FROM order_items

    JOIN products

    ON products.id=order_items.product_id

    WHERE order_id=%s

    """,(order_id,))

    items=cur.fetchall()

    conn.close()

    return render_template(

        "order.html",

        order=order,

        items=items

    )
    
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


@app.route("/vin", methods=["GET","POST"])
def vin_request():

    if request.method=="POST":

        vin=request.form["vin"]

        phone=request.form["phone"]

        comment=request.form["comment"]

        user_id=session.get("user_id")

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

            'Новый'

        )

        """,(

            user_id,

            vin,

            phone,

            comment

        ))

        conn.commit()

        conn.close()

        flash("Запрос успешно отправлен!")

        return redirect("/vin")

    return render_template("vin.html")


# ===========================================
# RUN
# ===========================================

if __name__ == "__main__":
    app.run(debug=True)
