-- =====================================================
-- FOOD DELIVERY APP - SUPABASE SCHEMA
-- Converted from MySQL to PostgreSQL
-- =====================================================

-- Drop existing types if they exist
DROP TYPE IF EXISTS user_role_enum CASCADE;
DROP TYPE IF EXISTS user_status_enum CASCADE;
DROP TYPE IF EXISTS shop_status_enum CASCADE;
DROP TYPE IF EXISTS payment_method_enum CASCADE;
DROP TYPE IF EXISTS payment_status_enum CASCADE;
DROP TYPE IF EXISTS order_status_enum CASCADE;

-- Create ENUM types
CREATE TYPE user_role_enum AS ENUM ('customer', 'shop_owner', 'admin');
CREATE TYPE user_status_enum AS ENUM ('inactive', 'active', 'suspended', 'banned');
CREATE TYPE shop_status_enum AS ENUM ('pending', 'approved', 'active', 'suspended', 'closed');
CREATE TYPE payment_method_enum AS ENUM ('COD', 'Momo', 'Banking');
CREATE TYPE payment_status_enum AS ENUM ('unpaid', 'paid');
CREATE TYPE order_status_enum AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed', 'cancelled');

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    supabase_uid VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    avatar VARCHAR(500),
    user_role user_role_enum DEFAULT 'customer',
    user_status user_status_enum DEFAULT 'inactive',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(user_role);
CREATE INDEX idx_users_supabase_uid ON users(supabase_uid);

-- =====================================================
-- USER ADDRESSES TABLE
-- =====================================================
CREATE TABLE user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    label VARCHAR(50),
    address TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);

-- =====================================================
-- CATEGORIES TABLE (Danh mục món ăn)
-- =====================================================
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SHOPS TABLE
-- =====================================================
CREATE TABLE shops (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    shop_name VARCHAR(255) NOT NULL,
    shop_description TEXT,
    cover_image VARCHAR(500),
    address TEXT NOT NULL,
    opening_time TIME,
    closing_time TIME,
    status shop_status_enum DEFAULT 'pending',
    rating_average DECIMAL(2, 1) DEFAULT 0,
    total_reviews INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ NULL,
    approved_by BIGINT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_shops_user_id ON shops(user_id);
CREATE INDEX idx_shops_status ON shops(status);
CREATE INDEX idx_shops_rating ON shops(rating_average);

-- =====================================================
-- SHOP CATEGORIES TABLE (1 shop có thể bán nhiều loại)
-- =====================================================
CREATE TABLE shop_categories (
    id BIGSERIAL PRIMARY KEY,
    shop_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE(shop_id, category_id)
);

CREATE INDEX idx_shop_categories_shop_id ON shop_categories(shop_id);
CREATE INDEX idx_shop_categories_category_id ON shop_categories(category_id);

-- =====================================================
-- FOOD ITEMS TABLE
-- =====================================================
CREATE TABLE food_items (
    id BIGSERIAL PRIMARY KEY,
    shop_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    food_name VARCHAR(255) NOT NULL,
    food_description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    discount_price DECIMAL(10, 2),
    image VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

CREATE INDEX idx_food_items_shop_id ON food_items(shop_id);
CREATE INDEX idx_food_items_category_id ON food_items(category_id);
CREATE INDEX idx_food_items_price ON food_items(price);

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL,
    shop_id BIGINT NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_phone VARCHAR(20) NOT NULL,
    delivery_note TEXT,
    subtotal DECIMAL(10, 2) NOT NULL,
    delivery_fee DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method payment_method_enum DEFAULT 'COD',
    payment_status payment_status_enum DEFAULT 'unpaid',
    order_status order_status_enum DEFAULT 'pending',
    cancelled_by BIGINT,
    cancel_reason TEXT,
    estimated_delivery_time TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ NULL,
    completed_at TIMESTAMPTZ NULL,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_orders_order_code ON orders(order_code);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_shop_id ON orders(shop_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- =====================================================
-- ORDER ITEMS TABLE (Chi tiết đơn hàng)
-- =====================================================
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    food_item_id BIGINT NOT NULL,
    food_name VARCHAR(255) NOT NULL,
    food_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    note TEXT,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_food_item_id ON order_items(food_item_id);

-- =====================================================
-- CART TABLE
-- =====================================================
CREATE TABLE cart (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    shop_id BIGINT NOT NULL,
    food_item_id BIGINT NOT NULL,
    quantity INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE,
    UNIQUE (user_id, shop_id, food_item_id)
);

CREATE INDEX idx_cart_user_id ON cart(user_id);
CREATE INDEX idx_cart_shop_id ON cart(shop_id);

-- =====================================================
-- REVIEWS TABLE
-- =====================================================
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    shop_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    images TEXT,
    shop_reply TEXT,
    replied_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_shop_id ON reviews(shop_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- =====================================================
-- ACTIVITY LOGS TABLE
-- =====================================================
CREATE TABLE activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update shop rating average
CREATE OR REPLACE FUNCTION update_shop_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE shops
    SET rating_average = (
        SELECT ROUND(AVG(rating)::numeric, 1)
        FROM reviews
        WHERE shop_id = NEW.shop_id
    ),
    total_reviews = (
        SELECT COUNT(*)
        FROM reviews
        WHERE shop_id = NEW.shop_id
    )
    WHERE id = NEW.shop_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update shop rating when review is added
CREATE TRIGGER trigger_update_shop_rating
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_shop_rating();

-- =====================================================
-- COMMENTS
-- =====================================================
COMMENT ON TABLE users IS 'Bảng người dùng - khách hàng, chủ shop, admin';
COMMENT ON TABLE user_addresses IS 'Địa chỉ giao hàng của người dùng';
COMMENT ON TABLE categories IS 'Danh mục món ăn';
COMMENT ON TABLE shops IS 'Thông tin cửa hàng';
COMMENT ON TABLE shop_categories IS 'Liên kết shop với nhiều danh mục';
COMMENT ON TABLE food_items IS 'Món ăn của từng shop';
COMMENT ON TABLE orders IS 'Đơn hàng';
COMMENT ON TABLE order_items IS 'Chi tiết món ăn trong đơn hàng';
COMMENT ON TABLE cart IS 'Giỏ hàng của người dùng';
COMMENT ON TABLE reviews IS 'Đánh giá của khách hàng';
COMMENT ON TABLE activity_logs IS 'Nhật ký hoạt động của người dùng';
