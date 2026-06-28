-- 1. users (no dependencies)
CREATE TABLE users (
    user_id           INT          PRIMARY KEY,
    full_name         VARCHAR      NOT NULL,
    email             VARCHAR      NOT NULL,
    date_of_birth     DATE         NOT NULL,
    country           VARCHAR      NOT NULL,
    account_status    VARCHAR      NOT NULL,
    kyc_status        VARCHAR      NOT NULL,
    user_tier         INT          NOT NULL,
    created_at        TIMESTAMP    NOT NULL,
    first_activity_at TIMESTAMP,
    suspension_reason VARCHAR
);

-- 2. logins (reference users)
CREATE TABLE logins (
    login_id	        INT          PRIMARY KEY,
    user_id	          INT          NOT NULL REFERENCES users(user_id),
    login_datetime	  TIMESTAMP    NOT NULL,
    ip_address        VARCHAR      NOT NULL,
    isp	              VARCHAR,
    iso2	            VARCHAR,
    state	            VARCHAR,
    useragent	        VARCHAR,
    screen_size	      VARCHAR,
    device_id	        VARCHAR      NOT NULL, -- assumed always captured; nullable in practice for privacy browsers
    device_type	      VARCHAR
);	

-- 3. payment_methods (reference users)
CREATE TABLE payment_methods (
    pm_id             INT           PRIMARY KEY,
    user_id	          INT           NOT NULL  REFERENCES users(user_id),
    payment_method    VARCHAR       NOT NULL,
    payment_provider  VARCHAR,
    card_number_masked  VARCHAR,
    card_bin           VARCHAR,
    destination_identifier VARCHAR,
    verified          BOOLEAN, -- 'verified', 'unverified', 'unknown'
    registered_at     TIMESTAMP     NOT NULL,
    first_used_at     TIMESTAMP,
    last_used_at      TIMESTAMP  
  );

-- 4. deposit 
CREATE TABLE deposits (	
    deposit_id	         INT           PRIMARY KEY,
    user_id	             INT           NOT NULL REFERENCES users(user_id),
    amount	             DECIMAL(10,2) NOT NULL,
    currency	          VARCHAR       NOT NULL,
    amount_gbp	         DECIMAL(10,2) NOT NULL,
    payment_method	     VARCHAR       NOT NULL,
    payment_provider	 VARCHAR,
    card_number_masked	 VARCHAR,
    card_bin	         VARCHAR,
    pm_id                INT    REFERENCES payment_methods(pm_id),
    pm_verification	     BOOLEAN, -- NULL for payment methods where verification is not applicable
    status	             VARCHAR      NOT NULL,
    result_description	 VARCHAR,
    dep_datetime	      TIMESTAMP    NOT NULL
    ip_address           VARCHAR
);	





