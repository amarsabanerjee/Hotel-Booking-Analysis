-- EDA Analysis
-- 1)Understand the distribution of arrival dates, including the most common arrival days and summary statistics for lead times.
-- Bookings per Year
SELECT 
    arrival_date_year,
    COUNT(*) AS total_bookings
FROM Booking_Details
GROUP BY arrival_date_year
ORDER BY arrival_date_year;
-- Bookings per Month
SELECT 
    arrival_date_month,
    COUNT(*) AS total_bookings
FROM Booking_Details
GROUP BY arrival_date_month
ORDER BY total_bookings DESC;
-- Bookings per Week Number
SELECT 
    arrival_date_week_number,
    COUNT(*) AS total_bookings
FROM Booking_Details
GROUP BY arrival_date_week_number
ORDER BY arrival_date_week_number;
-- Most Common Arrival Day of Month
SELECT 
    arrival_date_day_of_month,
    COUNT(*) AS total_arrivals
FROM Booking_Details
GROUP BY arrival_date_day_of_month
ORDER BY total_arrivals DESC;
-- Lead Time Summary Statistics
SELECT 
    MIN(lead_time) AS min_lead_time,
    MAX(lead_time) AS max_lead_time,
    AVG(lead_time) AS avg_lead_time,
    STDDEV(lead_time) AS stddev_lead_time
FROM Booking_Details;
-- Lead Time vs Cancellation
SELECT 
    CASE 
        WHEN lead_time <= 7 THEN '0-7 days'
        WHEN lead_time <= 30 THEN '8-30 days'
        WHEN lead_time <= 90 THEN '31-90 days'
        ELSE '90+ days'
    END AS lead_time_range,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    SUM(is_canceled) * 100.0 / COUNT(*) AS cancellation_rate
FROM Booking_Details
GROUP BY lead_time_range;

-- 2)Identify peak booking months and analyze reasons for spikes in bookings, including holidays or events.
SELECT 
    arrival_date_month,
    COUNT(*) AS total_bookings
FROM Booking_Details
GROUP BY arrival_date_month
ORDER BY total_bookings DESC;
-- 3)Calculate the average length of stays for different hotel types and explore variations by meal plans.
SELECT 
    bd.hotel,
    msd.meal,
    AVG(bd.stays_in_week_nights + bd.stays_in_weekend_nights) AS avg_stay
FROM Booking_Details bd
JOIN meal_and_stay_detail msd 
    ON bd.Booking_id = msd.Booking_id
GROUP BY bd.hotel, msd.meal
ORDER BY bd.hotel, avg_stay DESC;


-- 4)Analyze how booking patterns have evolved over the years, including yearoveryear changes in bookings and cancellations.
-- Year-wise bookings
SELECT 
    arrival_date_year,
    COUNT(*) AS total_bookings
FROM Booking_Details
GROUP BY arrival_date_year
ORDER BY arrival_date_year;
-- Year-wise cancellations
SELECT 
    arrival_date_year,
    SUM(is_canceled) AS canceled_bookings,
    SUM(is_canceled) * 100.0 / COUNT(*) AS cancellation_rate
FROM Booking_Details
GROUP BY arrival_date_year
ORDER BY arrival_date_year;
-- Year-over-Year (YoY) Growth
SELECT 
    a.arrival_date_year,
    a.total_bookings,
    b.total_bookings AS prev_year,
    (a.total_bookings - b.total_bookings) * 100.0 / b.total_bookings AS yoy_growth
FROM (
    SELECT arrival_date_year, COUNT(*) AS total_bookings
    FROM Booking_Details
    GROUP BY arrival_date_year
) a
LEFT JOIN (
    SELECT arrival_date_year, COUNT(*) AS total_bookings
    FROM Booking_Details
    GROUP BY arrival_date_year
) b
ON a.arrival_date_year = b.arrival_date_year + 1;
-- 5)Understand the distribution of the number of adults, children, and babies and identify any outliers.
-- Distribution of guests
SELECT 
    adults,
    children,
    babies,
    COUNT(*) AS total_bookings
FROM guest_info
GROUP BY adults, children, babies
ORDER BY total_bookings DESC;
-- Summary stats (to detect outliers)
SELECT 
    MIN(adults) AS min_adults,
    MAX(adults) AS max_adults,
    AVG(adults) AS avg_adults,
    MIN(children) AS min_children,
    MAX(children) AS max_children,
    AVG(children) AS avg_children,
    MIN(babies) AS min_babies,
    MAX(babies) AS max_babies,
    AVG(babies) AS avg_babies
FROM guest_info;
-- Outlier detection
SELECT *
FROM guest_info
WHERE adults > 4 
   OR children > 3 
   OR babies > 2;
-- 6)Calculate summary statistics for ADR and explore differences between Resort Hotel and City Hotel bookings.
-- Overall ADR summary
SELECT 
    MIN(adr) AS min_adr,
    MAX(adr) AS max_adr,
    AVG(adr) AS avg_adr,
    STDDEV(adr) AS stddev_adr
FROM meal_and_stay_detail;

-- ADR by hotel type
CREATE INDEX idx_bd_booking ON Booking_Details(Booking_id);
CREATE INDEX idx_msd_booking ON meal_and_stay_detail(Booking_id);
SELECT 
    bd.hotel,
    MIN(msd.adr) AS min_adr,
    MAX(msd.adr) AS max_adr,
    AVG(msd.adr) AS avg_adr,
    STDDEV(msd.adr) AS stddev_adr
FROM Booking_Details bd
JOIN meal_and_stay_detail msd 
    ON bd.Booking_id = msd.Booking_id
GROUP BY bd.hotel;

-- 7)Analyze the distribution of required car parking spaces for each hotel type and determine if one type attracts more guests with cars.
SELECT 
    bd.hotel,
    AVG(msd.required_car_parking_spaces) AS avg_parking,
    MAX(msd.required_car_parking_spaces) AS max_parking
FROM Booking_Details bd
JOIN meal_and_stay_detail msd 
    ON bd.Booking_id = msd.Booking_id
GROUP BY bd.hotel;
-- 8)Compare the total number of special requests made by different customer types (e.g., Transient, Group) and identify which customer type makes more requests.
SELECT 
    bsh.customer_type,
    SUM(msd.total_of_special_requests) AS total_requests
FROM Booking_source_and_history bsh
JOIN meal_and_stay_detail msd 
    ON bsh.Booking_id = msd.Booking_id
GROUP BY bsh.customer_type
ORDER BY total_requests DESC;
-- 9)Understand the distribution of meal plans (e.g., BB, HB, FB, SC) and identify any patterns or preferences.
SELECT 
    meal,
    COUNT(*) AS total_bookings
FROM meal_and_stay_detail
GROUP BY meal
ORDER BY total_bookings DESC;
-- 10)Analyze Average Daily Rates (ADR) by meal plan type to identify variations in pricing.
SELECT 
    meal,
    AVG(adr) AS avg_adr
FROM meal_and_stay_detail
WHERE adr > 0
GROUP BY meal
ORDER BY avg_adr DESC;
-- 11)Investigate the distribution of required car parking spaces and special requests by hotel type and meal plan.
SELECT 
    bd.hotel,
    msd.meal,
    AVG(msd.required_car_parking_spaces) AS avg_parking,
    AVG(msd.total_of_special_requests) AS avg_requests
FROM Booking_Details bd
JOIN meal_and_stay_detail msd 
    ON bd.Booking_id = msd.Booking_id
GROUP BY bd.hotel, msd.meal
ORDER BY bd.hotel;
-- 12)Compare the distribution of meal plans among different customer types (e.g., Transient, Group) to identify preferences.
SELECT 
    bsh.customer_type,
    msd.meal,
    COUNT(*) AS total_bookings
FROM Booking_source_and_history bsh
JOIN meal_and_stay_detail msd 
    ON bsh.Booking_id = msd.Booking_id
GROUP BY bsh.customer_type, msd.meal
ORDER BY bsh.customer_type, total_bookings DESC;
-- 13)Understand the distribution of bookings across different market segments and calculate summary statistics for lead times within each segment.
SELECT 
    ms.market_segment,
    COUNT(*) AS total_bookings,
    AVG(bd.lead_time) AS avg_lead_time,
    MIN(bd.lead_time) AS min_lead_time,
    MAX(bd.lead_time) AS max_lead_time
FROM Booking_Details bd
JOIN Booking_source_and_history bsh 
    ON bd.Booking_id = bsh.Booking_id
JOIN market_segment ms 
    ON bsh.market_segment_id = ms.market_segment_id
GROUP BY ms.market_segment
ORDER BY total_bookings DESC;
-- 14)Analyze the distribution of bookings through different booking channels (e.g., online travel agents, direct bookings) and calculate the percentage of bookings through each channel.
SELECT 
    dc.distribution_channel,
    COUNT(*) AS total_bookings,
    ROUND(
        COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM Booking_source_and_history), 
    2) AS percentage_share
FROM Booking_source_and_history bsh
JOIN distribution_channel dc 
    ON bsh.distribution_channel_id = dc.distribution_channel_id
GROUP BY dc.distribution_channel
ORDER BY total_bookings DESC;
-- 15)Calculate the proportion of repeated guests and investigate their booking behavior. Identify any patterns or differences in preferences compared to firsttime guests.
-- Proportion of Repeated vs New Guests
SELECT 
    customer_type,
    COUNT(*) AS total_bookings,
    ROUND(
        COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM Booking_source_and_history),
    2) AS percentage_share
FROM Booking_source_and_history
GROUP BY customer_type;
-- Behaviour Comparison
SELECT 
    bsh.customer_type,
    AVG(bd.lead_time) AS avg_lead_time,
    AVG(msd.adr) AS avg_adr,
    AVG(msd.total_of_special_requests) AS avg_requests
FROM Booking_source_and_history bsh
JOIN Booking_Details bd 
    ON bsh.Booking_id = bd.Booking_id
JOIN meal_and_stay_detail msd 
    ON bsh.Booking_id = msd.Booking_id
GROUP BY bsh.customer_type;
-- 16)Explore the impact of a guest's booking history on their likelihood of canceling a current booking. Calculate cancellation rates based on previous cancellations and noncanceled bookings.
SELECT 
    bsh.deposit_type,
    COUNT(*) AS total_bookings,
    SUM(bd.is_canceled) AS canceled_bookings,
    ROUND(SUM(bd.is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM Booking_source_and_history bsh
JOIN Booking_Details bd 
    ON bsh.Booking_id = bd.Booking_id
GROUP BY bsh.deposit_type;
-- 17)Understand the distribution of reserved and assigned room types. Calculate summary statistics for the consistency between reserved and assigned room types.
-- Reserved vs Assigned Room Type Analysis
SELECT 
    rd.reserved_room_type,
    rd.assigned_room_type,
    COUNT(*) AS total_bookings
FROM room_details rd
GROUP BY rd.reserved_room_type, rd.assigned_room_type
ORDER BY total_bookings DESC;
-- Consistency Check
SELECT 
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN reserved_room_type = assigned_room_type THEN 1 ELSE 0 END) AS same_room,
    SUM(CASE WHEN reserved_room_type != assigned_room_type THEN 1 ELSE 0 END) AS different_room,
    ROUND(
        SUM(CASE WHEN reserved_room_type = assigned_room_type THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ) AS consistency_rate
FROM room_details;
-- 18)Analyze the impact of booking changes on cancellation rates. Calculate cancellation rates for bookings with different numbers of changes.
SELECT 
    rd.booking_changes,
    COUNT(*) AS total_bookings,
    SUM(bd.is_canceled) AS canceled_bookings,
    ROUND(SUM(bd.is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM room_details rd
JOIN Booking_Details bd 
    ON rd.Booking_id = bd.Booking_id
GROUP BY rd.booking_changes
ORDER BY rd.booking_changes;
-- 19)Explore how room type preferences vary across different customer types (e.g., Transient, Group). Identify if certain customer types have specific room preferences.
ALTER TABLE Booking_source_and_history 
MODIFY Booking_id VARCHAR(50);

ALTER TABLE room_details 
MODIFY Booking_id VARCHAR(50);

CREATE INDEX idx_bsh_booking ON Booking_source_and_history(Booking_id);
CREATE INDEX idx_rd_booking ON room_details(Booking_id);
SELECT 
    bsh.customer_type,
    rd.reserved_room_type,
    COUNT(*) AS total_bookings
FROM Booking_source_and_history bsh
JOIN room_details rd 
    ON bsh.Booking_id = rd.Booking_id
GROUP BY bsh.customer_type, rd.reserved_room_type
ORDER BY bsh.customer_type, total_bookings DESC;
-- 20)Examine whether guests who make multiple bookings have consistent room type preferences or if their preferences change over time.
SELECT 
    bsh.customer_type,
    COUNT(DISTINCT rd.reserved_room_type) AS unique_room_types,
    COUNT(*) AS total_bookings
FROM Booking_source_and_history bsh
JOIN room_details rd 
    ON bsh.Booking_id = rd.Booking_id
GROUP BY bsh.customer_type;
-- 21)Understand the distribution of reservation statuses and calculate summary statistics for reservation status dates.
-- Status Distribution
SELECT 
    reservation_status,
    COUNT(*) AS total_bookings
FROM reservation_status
GROUP BY reservation_status
ORDER BY total_bookings DESC;
SELECT 
    MIN(reservation_status_date) AS earliest_date,
    MAX(reservation_status_date) AS latest_date,
    COUNT(*) AS total_records
FROM reservation_status;
-- 22)Analyze trends in reservation status dates, including the most common checkout dates and any seasonality patterns.
-- Most coomon check_out dates
SELECT 
    reservation_status_date,
    COUNT(*) AS total_checkouts
FROM reservation_status
WHERE reservation_status = 'Check-Out'
GROUP BY reservation_status_date
ORDER BY total_checkouts DESC;
-- Month wise trend 
SELECT 
    MONTH(reservation_status_date) AS month,
    COUNT(*) AS total_checkouts
FROM reservation_status
WHERE reservation_status = 'Check-Out'
GROUP BY MONTH(reservation_status_date)
ORDER BY total_checkouts DESC;
-- 23)Explore how reservation statuses vary across different customer types (e.g., Transient, Group) using Excel or SQL. Calculate cancellation rates by customer type.
SELECT 
    bsh.customer_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN rs.reservation_status = 'Canceled' THEN 1 ELSE 0 END) AS canceled_bookings,
    ROUND(
        SUM(CASE WHEN rs.reservation_status = 'Canceled' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ) AS cancellation_rate
FROM Booking_source_and_history bsh
JOIN reservation_status rs 
    ON bsh.Booking_id = rs.Booking_id
GROUP BY bsh.customer_type
ORDER BY cancellation_rate DESC;
-- 24)Investigate whether there are differences in Average Daily Rates (ADR) based on reservation status (e.g., canceled vs. checkedout).
SELECT 
    rs.reservation_status,
    AVG(msd.adr) AS avg_adr
FROM reservation_status rs
JOIN meal_and_stay_detail msd 
    ON rs.Booking_id = msd.Booking_id
WHERE msd.adr > 0
GROUP BY rs.reservation_status;