CREATE TABLE IF NOT EXISTS role (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    role_name VARCHAR(255) NOT NULL,
    role_code VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    privileges VARCHAR(50) NOT NULL DEFAULT 'READ_ONLY'
    );

-- ===============================
-- CREATE TABLE user
-- ===============================
CREATE TABLE IF NOT EXISTS user (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    email VARCHAR(255),
    phone_number VARCHAR(20),
    full_name VARCHAR(255),
    identify_number VARCHAR(20),
    gender VARCHAR(50),
    age INT,
    address VARCHAR(255),
    date_of_birth DATE,
    password VARCHAR(255),
    avatar_url VARCHAR(255),
    google_id VARCHAR(255),
    login_provider VARCHAR(255),

    role_id BIGINT NOT NULL,

    CONSTRAINT fk_user_role
    FOREIGN KEY (role_id)
    REFERENCES role(id)
    );