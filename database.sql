CREATE TABLE Customer (
    id VARCHAR(30) PRIMARY KEY,
    date_created TIMESTAMP NOT NULL,
    last_updated TIMESTAMP NOT NULL,
    is_deleted CHAR(1) NOT NULL DEFAULT 'N',
    status CHAR(1) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    name VARCHAR(100) NOT NULL,
    gender CHAR(1),
    birthday TIMESTAMP,
    city VARCHAR(50),
    customer_level VARCHAR(20)
);

CREATE TABLE User (
    id VARCHAR(30) PRIMARY KEY,
    date_created TIMESTAMP NOT NULL,
    customer_id VARCHAR(30) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
);

CREATE TABLE Store (
    id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    area VARCHAR(50),
    city VARCHAR(50) NOT NULL,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Product (
    id VARCHAR(30) PRIMARY KEY,
    date_created TIMESTAMP NOT NULL,
    last_updated TIMESTAMP NOT NULL,
    is_deleted CHAR(1) NOT NULL DEFAULT 'N',
    status CHAR(1) NOT NULL,
    name VARCHAR(100) NOT NULL,
    main_category VARCHAR(50) NOT NULL,
    category_level_1 VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Journey (
    id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    tracked_type VARCHAR(10) NOT NULL CHECK (tracked_type IN ('dynamic', 'fix')),
    start_time TIMESTAMP NOT NULL,
    duration INT,
    end_time TIMESTAMP,
    status CHAR(1) NOT NULL,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Transaction (
    id VARCHAR(30) PRIMARY KEY,
    external_transaction_id VARCHAR(50),
    tracked_time TIMESTAMP NOT NULL,
    flag INT NOT NULL CHECK (flag IN (1, 2, 3)),
    customer_id VARCHAR(30),
    store_id VARCHAR(30) NOT NULL,
    product_id VARCHAR(30),
    revenue DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(id),
    FOREIGN KEY (store_id) REFERENCES Store(id),
    FOREIGN KEY (product_id) REFERENCES Product(id)
);


CREATE TABLE Promotion_Code (
    id VARCHAR(30) PRIMARY KEY,
    promotion_code VARCHAR(20) NOT NULL,
    transaction_id VARCHAR(30),
    status VARCHAR(20) NOT NULL,
    journey_id VARCHAR(30) NOT NULL,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (journey_id) REFERENCES Journey(id),
    FOREIGN KEY (transaction_id) REFERENCES Transaction(id)
);

CREATE TABLE Delivery (
    id VARCHAR(30) PRIMARY KEY,
    allocated_audience VARCHAR(30) NOT NULL,
    tracked_time TIMESTAMP NOT NULL,
    journey_id VARCHAR(30) NOT NULL,
    FOREIGN KEY (allocated_audience) REFERENCES Customer(id),
    FOREIGN KEY (journey_id) REFERENCES Journey(id)
);

-- Add useful indexes
CREATE INDEX idx_customer_email ON Customer(email);
CREATE INDEX idx_transaction_customer ON Transaction(customer_id);
CREATE INDEX idx_transaction_store ON Transaction(store_id);
CREATE INDEX idx_transaction_product ON Transaction(product_id);
CREATE INDEX idx_promotion_journey ON Promotion_Code(journey_id);
CREATE INDEX idx_delivery_journey ON Delivery(journey_id);
CREATE INDEX idx_delivery_audience ON Delivery(allocated_audience);