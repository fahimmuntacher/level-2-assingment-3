-- create user role enum
create type role as enum('admin', 'customer');

-- create table
create table users (
  id serial primary key,
  name varchar(50),
  email varchar(100) unique,
  password varchar(50) not null,
  role role,
  phone_number int
)
-- create car type as enum 
create type type as enum('car', 'bike', 'truck');

-- availability type enum
create type availablity as enum('available', 'rented', 'maintaince');

-- vehicle table
create table vehicles (
  id serial primary key,
  vehicle_name varchar(100),
  type type,
  registration_number varchar(100) unique,
  rental_price int,
  availability availablity
)
-- drop table vehicles
select
  *
from
  vehicles
  -- create booking_status type 
create type booking_status as enum('pending', 'confirmed', 'completed', 'cancelled')
-- create booking table
CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users (id),
  vehicle_id INT REFERENCES vehicles (id),
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  booking_status booking_status,
  total_cost DECIMAL(10, 2)
);

select
  *
from
  bookings
  -- Create trigger function
CREATE OR REPLACE FUNCTION calculate_total_cost () RETURNS TRIGGER AS $$
BEGIN
  SELECT rental_price * EXTRACT(DAY FROM (NEW.end_date - NEW.start_date))
  INTO NEW.total_cost
  FROM vehicles
  WHERE id = NEW.vehicle_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER set_total_cost BEFORE INSERT
OR
UPDATE ON bookings FOR EACH ROW
EXECUTE FUNCTION calculate_total_cost ();

-- join 
-- Retrieve booking information along with customer name and vehicle name
select
  b.id as booking_id,
  u.name as user_name,
  v.vehicle_name,
  b.start_date,
  b.end_date,
  b.total_cost
from
  bookings b
  inner join users u on b.user_id = u.id
  inner join vehicles v on b.vehicle_id = v.id
  
  -- exist 
  -- find the 
select
  *
from
  vehicles v
where
  not exists (
    select
      1
    from
      bookings b
    where
      b.vehicle_id = v.id
  )

-- Query 3: WHERE
-- Retrieve all available vehicles of a specific type (cars)
select *
from vehicles
where type = 'bike' 
  and availability = 'rented';

-- Query 4: GROUP BY and HAVING
-- Find the total number of bookings for each vehicle 
-- and display only those vehicles that have more than 2 bookings
select 
  v.id as vehicle_id,
  v.vehicle_name,
  v.type,
  count(b.id) as total_bookings
from vehicles v
inner join bookings b on v.id = b.vehicle_id
group by v.id, v.vehicle_name, v.type
having count(b.id) > 2
order by total_bookings desc;