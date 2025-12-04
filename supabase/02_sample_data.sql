-- =====================================================
-- FOOD DELIVERY APP - SAMPLE DATA
-- Dữ liệu mẫu cho ứng dụng giao đồ ăn
-- =====================================================

-- =====================================================
-- 1. USERS (Người dùng)
-- =====================================================
INSERT INTO users (email, user_password, full_name, phone, avatar, user_role, user_status, is_verified) VALUES
-- Admin accounts
('admin@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Nguyễn Văn Admin', '0901234567', 'https://i.pravatar.cc/150?img=1', 'admin', 'active', true),
('admin2@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Trần Thị Quản Trị', '0901234568', 'https://i.pravatar.cc/150?img=2', 'admin', 'active', true),

-- Shop owners
('owner.pho@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Lê Văn Phở', '0912345678', 'https://i.pravatar.cc/150?img=11', 'shop_owner', 'active', true),
('owner.banhmi@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Phạm Thị Bánh Mì', '0912345679', 'https://i.pravatar.cc/150?img=12', 'shop_owner', 'active', true),
('owner.coffee@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Hoàng Văn Cà Phê', '0912345680', 'https://i.pravatar.cc/150?img=13', 'shop_owner', 'active', true),
('owner.comtam@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Võ Thị Cơm Tấm', '0912345681', 'https://i.pravatar.cc/150?img=14', 'shop_owner', 'active', true),
('owner.tratra@foodapp.vn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Đặng Văn Trà', '0912345682', 'https://i.pravatar.cc/150?img=15', 'shop_owner', 'active', true),

-- Customers
('khach1@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Nguyễn Minh Khách', '0923456789', 'https://i.pravatar.cc/150?img=21', 'customer', 'active', true),
('khach2@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Trần Thị Hương', '0923456790', 'https://i.pravatar.cc/150?img=22', 'customer', 'active', true),
('khach3@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Lê Văn Bình', '0923456791', 'https://i.pravatar.cc/150?img=23', 'customer', 'active', true),
('khach4@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Phạm Thị Chi', '0923456792', 'https://i.pravatar.cc/150?img=24', 'customer', 'active', false),
('khach5@gmail.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhCu', 'Hoàng Văn Dũng', '0923456793', 'https://i.pravatar.cc/150?img=25', 'customer', 'inactive', false);

-- =====================================================
-- 2. USER ADDRESSES (Địa chỉ người dùng)
-- =====================================================
INSERT INTO user_addresses (user_id, label, address, is_default) VALUES
-- Khách 1
(8, 'Nhà riêng', '123 Nguyễn Huệ, Quận 1, TP.HCM', true),
(8, 'Công ty', '456 Lê Lợi, Quận 1, TP.HCM', false),
-- Khách 2
(9, 'Nhà', '789 Trần Hưng Đạo, Quận 5, TP.HCM', true),
-- Khách 3
(10, 'Nhà riêng', '321 Võ Văn Tần, Quận 3, TP.HCM', true),
(10, 'Nhà bạn', '654 Pasteur, Quận 1, TP.HCM', false),
-- Khách 4
(11, 'Nhà', '111 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM', true);

-- =====================================================
-- 3. CATEGORIES (Danh mục món ăn)
-- =====================================================
INSERT INTO categories (category_name, category_description) VALUES
('Phở & Bún', 'Các món phở, bún truyền thống Việt Nam'),
('Cơm', 'Các món cơm: cơm tấm, cơm sườn, cơm gà...'),
('Bánh mì', 'Bánh mì Việt Nam với nhiều nhân đa dạng'),
('Đồ uống', 'Nước giải khát, sinh tố, nước ép'),
('Cà phê', 'Cà phê phin, cà phê sữa, espresso...'),
('Trà sữa', 'Trà sữa, trà trái cây, topping đa dạng'),
('Món ăn vặt', 'Chả giò, nem rán, gỏi cuốn...'),
('Tráng miệng', 'Chè, bánh flan, yaourt...');

-- =====================================================
-- 4. SHOPS (Cửa hàng)
-- =====================================================
INSERT INTO shops (user_id, shop_name, shop_description, cover_image, address, opening_time, closing_time, status, rating_average, total_reviews, approved_at, approved_by) VALUES
(3, 'Phở Hà Nội 24h', 'Phở bò, phở gà chính gốc Hà Nội, nước dùng ninh từ xương 12 tiếng', 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800', '123 Lý Thường Kiệt, Quận 10, TP.HCM', '00:00:00', '23:59:59', 'active', 4.5, 0, NOW() - INTERVAL '30 days', 1),
(4, 'Bánh Mì Huỳnh Hoa', 'Bánh mì đặc biệt với nhân thịt nguội, pate, chả lụa thơm ngon', 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800', '26 Lê Thị Riêng, Quận 1, TP.HCM', '06:00:00', '22:00:00', 'active', 4.8, 0, NOW() - INTERVAL '60 days', 1),
(5, 'Highlands Coffee', 'Chuỗi cà phê Việt Nam với không gian hiện đại, thức uống đa dạng', 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800', '100 Nguyễn Văn Cừ, Quận 5, TP.HCM', '07:00:00', '22:00:00', 'active', 4.3, 0, NOW() - INTERVAL '90 days', 1),
(6, 'Cơm Tấm Mộc', 'Cơm tấm sườn nướng, bì, chả trứng đậm đà hương vị miền Nam', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800', '234 Cách Mạng Tháng 8, Quận 3, TP.HCM', '06:30:00', '21:00:00', 'active', 4.6, 0, NOW() - INTERVAL '45 days', 1),
(7, 'Trà Sữa Gongcha', 'Trà sữa Đài Loan chính gốc, topping phong phú', 'https://images.unsplash.com/photo-1525385133512-2f3bdd039054?w=800', '567 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM', '08:00:00', '23:00:00', 'pending', 0, 0, NULL, NULL);

-- =====================================================
-- 5. SHOP CATEGORIES (Liên kết shop với danh mục)
-- =====================================================
INSERT INTO shop_categories (shop_id, category_id) VALUES
-- Phở Hà Nội 24h
(1, 1), -- Phở & Bún
(1, 4), -- Đồ uống
-- Bánh Mì Huỳnh Hoa
(2, 3), -- Bánh mì
(2, 4), -- Đồ uống
-- Highlands Coffee
(3, 5), -- Cà phê
(3, 4), -- Đồ uống
(3, 8), -- Tráng miệng
-- Cơm Tấm Mộc
(4, 2), -- Cơm
(4, 4), -- Đồ uống
-- Trà Sữa Gongcha
(5, 6), -- Trà sữa
(5, 4); -- Đồ uống

-- =====================================================
-- 6. FOOD ITEMS (Món ăn)
-- =====================================================
INSERT INTO food_items (shop_id, category_id, food_name, food_description, price, discount_price, image) VALUES
-- Phở Hà Nội 24h
(1, 1, 'Phở Bò Tái', 'Phở bò tái chín, nước dùng trong, thơm ngon', 55000, NULL, 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400'),
(1, 1, 'Phở Bò Đặc Biệt', 'Phở bò đầy đủ: tái, nạm, gân, sách', 70000, 65000, 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400'),
(1, 1, 'Phở Gà', 'Phở gà nước dùng ngọt thanh, thịt gà mềm', 50000, NULL, 'https://images.unsplash.com/photo-1626804475297-41608ea09aeb?w=400'),
(1, 1, 'Bún Bò Huế', 'Bún bò Huế cay nồng đậm đà', 60000, NULL, 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400'),
(1, 4, 'Trà Đá', 'Trà đá miễn phí khi order phở', 0, NULL, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400'),

-- Bánh Mì Huỳnh Hoa
(2, 3, 'Bánh Mì Đặc Biệt', 'Bánh mì thập cẩm đầy đủ nhân', 25000, NULL, 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400'),
(2, 3, 'Bánh Mì Thịt Nướng', 'Bánh mì thịt nướng thơm lừng', 22000, 20000, 'https://images.unsplash.com/photo-1598511726623-d2e9996892f0?w=400'),
(2, 3, 'Bánh Mì Pate', 'Bánh mì pate truyền thống', 15000, NULL, 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=400'),
(2, 3, 'Bánh Mì Trứng Ốp La', 'Bánh mì trứng ốp la cho bữa sáng', 18000, NULL, 'https://images.unsplash.com/photo-1619096252214-ef06c45683e3?w=400'),
(2, 4, 'Sữa Đậu Nành', 'Sữa đậu nành tươi nguyên chất', 10000, NULL, 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400'),

-- Highlands Coffee
(3, 5, 'Phin Sữa Đá', 'Cà phê phin truyền thống Việt Nam', 39000, NULL, 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400'),
(3, 5, 'Bạc Xỉu', 'Cà phê sữa ngọt ngào', 39000, NULL, 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400'),
(3, 5, 'Cappuccino', 'Cappuccino Ý đậm đà', 49000, 45000, 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400'),
(3, 5, 'Latte', 'Latte mềm mại hương vị', 49000, NULL, 'https://images.unsplash.com/photo-1561882468-9110e03e0f78?w=400'),
(3, 4, 'Trà Xanh Latte', 'Trà xanh latte thơm ngon', 49000, NULL, 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400'),
(3, 8, 'Bánh Flan', 'Bánh flan caramel mềm mịn', 25000, NULL, 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=400'),

-- Cơm Tấm Mộc
(4, 2, 'Cơm Tấm Sườn Bì Chả', 'Cơm tấm truyền thống đầy đủ', 45000, NULL, 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400'),
(4, 2, 'Cơm Tấm Sườn Nướng', 'Cơm tấm sườn nướng thơm phức', 40000, 38000, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400'),
(4, 2, 'Cơm Tấm Gà Nướng', 'Cơm tấm gà nướng mật ong', 42000, NULL, 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400'),
(4, 2, 'Cơm Tấm Bì Chả', 'Cơm tấm bì chả cho người ăn nhẹ', 35000, NULL, 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400'),
(4, 4, 'Trà Đá', 'Trà đá giải khát', 5000, NULL, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400'),

-- Trà Sữa Gongcha
(5, 6, 'Trà Sữa Truyền Thống', 'Trà sữa Đài Loan nguyên bản', 45000, NULL, 'https://images.unsplash.com/photo-1525385133512-2f3bdd039054?w=400'),
(5, 6, 'Trà Sữa Trân Châu Đường Đen', 'Trà sữa trân châu đường đen hot trend', 55000, 50000, 'https://images.unsplash.com/photo-1525385133512-2f3bdd039054?w=400'),
(5, 6, 'Trà Oolong', 'Trà oolong thanh mát', 40000, NULL, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400'),
(5, 6, 'Trà Đào Cam Sả', 'Trà đào cam sả tươi mát', 50000, NULL, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400'),
(5, 4, 'Sinh Tố Bơ', 'Sinh tố bơ béo ngậy', 45000, NULL, 'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?w=400');

-- =====================================================
-- 7. ORDERS (Đơn hàng)
-- =====================================================
INSERT INTO orders (order_code, customer_id, shop_id, delivery_address, delivery_phone, delivery_note, subtotal, delivery_fee, discount_amount, total_amount, payment_method, payment_status, order_status, estimated_delivery_time, created_at, confirmed_at, completed_at) VALUES
-- Đơn đã hoàn thành
('ORD001', 8, 1, '123 Nguyễn Huệ, Quận 1, TP.HCM', '0923456789', 'Gọi trước khi giao', 125000, 15000, 0, 140000, 'COD', 'paid', 'completed', NOW() - INTERVAL '2 days' + INTERVAL '30 minutes', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '5 minutes', NOW() - INTERVAL '2 days'),
('ORD002', 9, 2, '789 Trần Hưng Đạo, Quận 5, TP.HCM', '0923456790', NULL, 47000, 20000, 0, 67000, 'Momo', 'paid', 'completed', NOW() - INTERVAL '1 day' + INTERVAL '25 minutes', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '3 minutes', NOW() - INTERVAL '1 day'),
('ORD003', 10, 3, '321 Võ Văn Tần, Quận 3, TP.HCM', '0923456791', 'Không gọi chuông', 98000, 15000, 0, 113000, 'Banking', 'paid', 'completed', NOW() - INTERVAL '12 hours' + INTERVAL '30 minutes', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '2 minutes', NOW() - INTERVAL '12 hours'),

-- Đơn đang giao
('ORD004', 8, 4, '123 Nguyễn Huệ, Quận 1, TP.HCM', '0923456789', NULL, 85000, 15000, 10000, 90000, 'COD', 'unpaid', 'delivering', NOW() + INTERVAL '15 minutes', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '40 minutes', NULL),

-- Đơn đang chuẩn bị
('ORD005', 9, 1, '789 Trần Hưng Đạo, Quận 5, TP.HCM', '0923456790', 'Cho thêm rau', 120000, 20000, 0, 140000, 'Momo', 'paid', 'preparing', NOW() + INTERVAL '30 minutes', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '18 minutes', NULL),

-- Đơn chờ xác nhận
('ORD006', 10, 2, '321 Võ Văn Tần, Quận 3, TP.HCM', '0923456791', NULL, 40000, 15000, 0, 55000, 'COD', 'unpaid', 'pending', NOW() + INTERVAL '40 minutes', NOW() - INTERVAL '5 minutes', NULL, NULL),

-- Đơn đã hủy
('ORD007', 11, 3, '111 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM', '0923456792', NULL, 98000, 18000, 0, 116000, 'COD', 'unpaid', 'cancelled', NULL, NOW() - INTERVAL '4 days', NULL, NULL);

-- =====================================================
-- 8. ORDER ITEMS (Chi tiết đơn hàng)
-- =====================================================
INSERT INTO order_items (order_id, food_item_id, food_name, food_price, quantity, note, subtotal) VALUES
-- ORD001
(1, 2, 'Phở Bò Đặc Biệt', 65000, 1, 'Ít hành', 65000),
(1, 3, 'Phở Gà', 50000, 1, NULL, 50000),
(1, 5, 'Trà Đá', 0, 2, NULL, 0),

-- ORD002
(2, 6, 'Bánh Mì Đặc Biệt', 25000, 1, NULL, 25000),
(2, 7, 'Bánh Mì Thịt Nướng', 20000, 1, 'Không ớt', 20000),

-- ORD003
(3, 11, 'Phin Sữa Đá', 39000, 1, NULL, 39000),
(3, 13, 'Cappuccino', 45000, 1, NULL, 45000),
(3, 16, 'Bánh Flan', 25000, 1, NULL, 25000),

-- ORD004
(4, 17, 'Cơm Tấm Sườn Bì Chả', 45000, 1, NULL, 45000),
(4, 18, 'Cơm Tấm Sườn Nướng', 38000, 1, 'Thêm mỡ hành', 38000),

-- ORD005
(5, 1, 'Phở Bò Tái', 55000, 2, NULL, 110000),
(5, 5, 'Trà Đá', 0, 2, NULL, 0),

-- ORD006
(6, 8, 'Bánh Mì Pate', 15000, 2, NULL, 30000),
(6, 10, 'Sữa Đậu Nành', 10000, 1, NULL, 10000),

-- ORD007
(7, 11, 'Phin Sữa Đá', 39000, 1, NULL, 39000),
(7, 12, 'Bạc Xỉu', 39000, 1, NULL, 39000),
(7, 14, 'Latte', 49000, 1, NULL, 49000);

-- Update cancelled order
UPDATE orders SET cancelled_by = 11, cancel_reason = 'Đổi ý, không muốn order nữa' WHERE id = 7;

-- =====================================================
-- 9. CART (Giỏ hàng)
-- =====================================================
INSERT INTO cart (user_id, shop_id, food_item_id, quantity) VALUES
-- Khách 1 đang có món trong giỏ từ shop Phở
(8, 1, 1, 2),
(8, 1, 4, 1),

-- Khách 2 đang có món trong giỏ từ shop Highlands
(9, 3, 11, 1),
(9, 3, 13, 2),

-- Khách 3 đang có món trong giỏ từ shop Cơm Tấm
(10, 4, 17, 1),
(10, 4, 21, 2);

-- =====================================================
-- 10. REVIEWS (Đánh giá)
-- =====================================================
INSERT INTO reviews (order_id, customer_id, shop_id, rating, comment, images, shop_reply, replied_at) VALUES
-- Reviews cho đơn đã hoàn thành
(1, 8, 1, 5, 'Phở rất ngon, nước dùng trong, thơm. Giao hàng nhanh!', NULL, 'Cảm ơn bạn đã ủng hộ quán! Hẹn gặp lại bạn lần sau.', NOW() - INTERVAL '1 day'),
(2, 9, 2, 5, 'Bánh mì đặc biệt quá, nhân đầy đủ, giá hợp lý', NULL, 'Cảm ơn bạn nhiều! Chúc bạn ngon miệng!', NOW() - INTERVAL '20 hours'),
(3, 10, 3, 4, 'Cà phê ngon nhưng hơi đắt. Không gian đẹp', NULL, NULL, NULL);

-- =====================================================
-- 11. ACTIVITY LOGS (Nhật ký hoạt động)
-- =====================================================
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES
(1, 'LOGIN', 'Admin đăng nhập hệ thống', '192.168.1.100'),
(8, 'REGISTER', 'Khách hàng đăng ký tài khoản mới', '192.168.1.101'),
(8, 'LOGIN', 'Khách hàng đăng nhập', '192.168.1.101'),
(8, 'ORDER_CREATED', 'Tạo đơn hàng ORD001', '192.168.1.101'),
(3, 'ORDER_CONFIRMED', 'Xác nhận đơn hàng ORD001', '192.168.1.102'),
(8, 'ORDER_COMPLETED', 'Hoàn thành đơn hàng ORD001', '192.168.1.101'),
(8, 'REVIEW_CREATED', 'Đánh giá đơn hàng ORD001', '192.168.1.101'),
(9, 'LOGIN', 'Khách hàng đăng nhập', '192.168.1.103'),
(9, 'ORDER_CREATED', 'Tạo đơn hàng ORD002', '192.168.1.103'),
(10, 'LOGIN', 'Khách hàng đăng nhập', '192.168.1.104'),
(11, 'ORDER_CANCELLED', 'Hủy đơn hàng ORD007', '192.168.1.105');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Uncomment to verify data

-- SELECT 'Users Count' as info, COUNT(*) as count FROM users;
-- SELECT 'Shops Count' as info, COUNT(*) as count FROM shops;
-- SELECT 'Food Items Count' as info, COUNT(*) as count FROM food_items;
-- SELECT 'Orders Count' as info, COUNT(*) as count FROM orders;
-- SELECT 'Reviews Count' as info, COUNT(*) as count FROM reviews;

-- Show shops with their ratings
-- SELECT shop_name, rating_average, total_reviews, status FROM shops ORDER BY rating_average DESC;

-- Show orders by status
-- SELECT order_status, COUNT(*) as count FROM orders GROUP BY order_status;
