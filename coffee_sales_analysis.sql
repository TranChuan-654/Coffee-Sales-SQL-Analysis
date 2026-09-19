--Monday Coffee -- Data Analysis

SELECT * FROM city
SELECT * FROM customers
SELECT * FROM Products
SELECT * FROM sales

-- Reports & Data Analysis 

-- 1. Số lượng người tiêu thụ cà phê
-- Ước tính có bao nhiêu người ở mỗi thành phố tiêu thụ cà phê, với giả định 25% dân số có uống cà phê? 
SELECT 
	city_name,
	ROUND((population * 0.25)/1000000,2) as coffee_consumers_in_million ,
	city_rank
FROM city
ORDER BY 2 DESC

-- 2.Tổng doanh thu từ việc bán cà phê
-- Tổng doanh thu từ việc bán cà phê tại tất cả các thành phố trong quý cuối cùng của năm 2023 là bao nhiêu?

SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue
FROM sales as s
INNER JOIN customers as c
ON c.customer_id = c.customer_id
INNER JOIN city as ci
ON ci.city_id = c.city_id
WHERE 	EXTRACT(YEAR FROM s.sale_date) = 2023
		AND 
		EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC

-- 3.Số lượng bán ra của từng sản phẩm
-- Mỗi sản phẩm cà phê đã bán được bao nhiêu đơn vị (sản phẩm)?
SELECT 
	p.product_name,
	COUNT(s.sale_id) as total_orders
FROM products as p
LEFT JOIN 
sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC

-- 4. Doanh số bán hàng trung bình trên mỗi thành phố
-- Doanh số bán hàng trung bình trên mỗi khách hàng ở mỗi thành phố là bao nhiêu 

SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT(c.customer_id)) as total_cx,
	ROUND (SUM(s.total)::numeric/COUNT(DISTINCT(c.customer_id)::numeric),2) as avg_sale_pr_xc
FROM sales as s
INNER JOIN customers as c
ON c.customer_id = s.customer_id
INNER JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1 
ORDER BY 2 DESC

--5. Dân số thành phố và số người tiêu thụ cà phê
--   Hãy cung cấp danh sách các thành phố cùng với dân số và số người tiêu thụ cà phê ước tính.
WITH city_table AS 
(
    SELECT 
        city_name,
        ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers
    FROM city
),
customers_table AS
(
    SELECT 
        ci.city_name,
        COUNT(DISTINCT s.customer_id) AS unique_cx
    FROM sales AS s
    JOIN customers AS c
        ON c.customer_id = s.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY 1
)
SELECT 
    customers_table.city_name,
    city_table.coffee_consumers AS coffee_consumer_in_millions,
    customers_table.unique_cx
FROM city_table
JOIN customers_table
    ON city_table.city_name = customers_table.city_name;

-- 6.Các sản phẩm bán chạy nhất theo từng thành phố
-- 3 sản phẩm bán chạy nhất ở mỗi thành phố dựa trên số lượng sản phẩm đã bán là gì?

SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3

-- 7.Phân loại khách hàng theo thành phố
-- Có bao nhiêu khách hàng duy nhất ở mỗi thành phố đã mua các sản phẩm cà phê?
SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id BETWEEN 1 AND 14
GROUP BY 1

-- 8 Doanh số bán hàng trung bình so với tiền thuê
-- Tìm từng thành phố, doanh số bán hàng trung bình trên mỗi khách hàng và tiền thuê trung bình trên mỗi khách hàng

WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 	
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
INNER JOIN city_table as ct
ON ct.city_name = cr.city_name
ORDER BY 4 desc

-- 9.Tăng trưởng doanh số bán hàng theo tháng
-- Tỷ lệ tăng trưởng doanh số: Tính phần trăm tăng (hoặc giảm) doanh số qua các khoảng thời gian khác nhau (theo tháng)

WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as YEAR,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
		, 2
		) as growth_ratio

FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	
-- 10. Phân tích tiềm năng thị trường
-- Xác định 3 thành phố có doanh số bán hàng cao nhất, và trả về tên thành phố, tổng doanh số, tổng tiền thuê, tổng số khách hàng và số người tiêu thụ cà phê ước tính.
WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC
/*
-- Đề xuất

Thành phố 1: Pune
    1. Tiền thuê trung bình trên mỗi khách hàng rất thấp.
    2. Tổng doanh thu cao nhất.
    3. Doanh số trung bình trên mỗi khách hàng cũng cao.

Thành phố 2: Delhi
    1. Số người tiêu thụ cà phê ước tính cao nhất, lên tới 7,7 triệu người.
    2. Có tổng số khách hàng cao nhất, là 68 khách hàng.
    3. Tiền thuê trung bình trên mỗi khách hàng là 330 (vẫn dưới 500).

Thành phố 3: Jaipur
    1. Có số lượng khách hàng cao nhất, là 69 khách hàng.
    2. Tiền thuê trung bình trên mỗi khách hàng rất thấp, ở mức 156.
    3. Doanh số trung bình trên mỗi khách hàng khá tốt, ở mức 11,6 nghìn.
*/