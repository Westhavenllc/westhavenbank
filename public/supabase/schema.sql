-- =============================================
-- COMPLETE DATABASE SCHEMA (IDEMPOTENT & SELF-UPDATING)
-- Generated from existing database structure
-- Tables: 18 | Views: 3 | Total: 21
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- TABLES (18) & COLUMN UPDATES
-- =============================================

-- =============================================
-- TABLE: users
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS instance_id UUID;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR NOT NULL UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS aud VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date DATE NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_confirmed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS invited_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS country VARCHAR NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS confirmation_token VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS government_id_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS confirmation_sent_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_picture_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS recovery_token VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS recovery_phrase_hash TEXT NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS transaction_pin_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS recovery_sent_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_change_token_new VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS account_type VARCHAR NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_change VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_change_sent_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_sign_in_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS otp_code VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS otp_expires_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS raw_app_meta_data JSONB;
ALTER TABLE users ADD COLUMN IF NOT EXISTS raw_user_meta_data JSONB;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_super_admin BOOLEAN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_level INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_upgrade_status VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_confirmed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_change TEXT DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_upgrade_requested_to INTEGER;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_disabled BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS disabled_reason TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_change_token VARCHAR DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_change_sent_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_change_token_current VARCHAR DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_change_confirm_status SMALLINT DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS banned_until TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reauthentication_token VARCHAR DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS reauthentication_sent_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_sso_user BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_anonymous BOOLEAN DEFAULT false;

-- =============================================
-- TABLE: accounts
-- =============================================
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE accounts ADD COLUMN IF NOT EXISTS account_number VARCHAR NOT NULL UNIQUE;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS balance NUMERIC DEFAULT 0.00;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS currency VARCHAR DEFAULT 'USD';
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'active';
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS btc_address TEXT;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS ltc_address TEXT;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS btc_balance NUMERIC DEFAULT 0.00000000;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS ltc_balance NUMERIC DEFAULT 0.00000000;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS gas_balance NUMERIC DEFAULT 0.00;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS gas_wallet_address TEXT;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS gas_wallet_network VARCHAR;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS allow_withdrawal BOOLEAN DEFAULT true NOT NULL;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS withdrawal_alert_msg TEXT;

-- =============================================
-- TABLE: admin_notifications
-- =============================================
CREATE TABLE IF NOT EXISTS admin_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS notification_type VARCHAR NOT NULL;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS title VARCHAR NOT NULL;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS message TEXT NOT NULL;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS action_type VARCHAR;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS action_data JSONB;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;
ALTER TABLE admin_notifications ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- =============================================
-- TABLE: admin_review_queue
-- =============================================
CREATE TABLE IF NOT EXISTS admin_review_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS review_type VARCHAR NOT NULL;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS reference_id UUID NOT NULL;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS reference_table VARCHAR NOT NULL;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS priority VARCHAR DEFAULT 'medium' NOT NULL;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending' NOT NULL;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS assigned_to UUID;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS review_notes TEXT;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS approved_by UUID;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE admin_review_queue ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMP WITH TIME ZONE;

-- =============================================
-- TABLE: beneficiaries
-- =============================================
CREATE TABLE IF NOT EXISTS beneficiaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS user_id UUID NOT NULL;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS beneficiary_reference VARCHAR NOT NULL UNIQUE;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS bank_name VARCHAR NOT NULL;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS account_number VARCHAR NOT NULL;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS account_name VARCHAR NOT NULL;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS routing_number VARCHAR;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS swift_code VARCHAR;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS iban VARCHAR;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS account_type VARCHAR DEFAULT 'checking';
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS country VARCHAR DEFAULT 'United States';
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS is_us_bank BOOLEAN DEFAULT true;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS bank_address TEXT;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS email VARCHAR;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS phone VARCHAR;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS nickname VARCHAR;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS transfer_count INTEGER DEFAULT 0;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS last_used_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE beneficiaries ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;

-- =============================================
-- TABLE: card_applications
-- =============================================
CREATE TABLE IF NOT EXISTS card_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS application_reference VARCHAR NOT NULL UNIQUE;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS initiated_by_user_id UUID;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS approved_by_user_id UUID;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS pending_action_id UUID;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS card_type VARCHAR NOT NULL;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS card_network VARCHAR NOT NULL;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS card_tier VARCHAR;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS annual_income NUMERIC;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS employment_status VARCHAR;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS credit_score INTEGER;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS transaction_id UUID;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending' NOT NULL;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS admin_notes TEXT;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS issued_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS wallet_type VARCHAR DEFAULT 'usd';
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS crypto_coin VARCHAR;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS delivery_type VARCHAR DEFAULT 'digital';
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS shipping_name TEXT;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS shipping_address TEXT;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS card_number VARCHAR;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS card_expiry VARCHAR;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS card_holder VARCHAR;
ALTER TABLE card_applications ADD COLUMN IF NOT EXISTS amount NUMERIC;

-- =============================================
-- TABLE: cards
-- =============================================
CREATE TABLE IF NOT EXISTS cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_number_encrypted TEXT NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_number_hash TEXT NOT NULL UNIQUE;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS last_four VARCHAR NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS application_id UUID;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_type VARCHAR NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS network VARCHAR NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS card_tier VARCHAR;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS expiry_month INTEGER NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS expiry_year INTEGER NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS cvv_encrypted TEXT NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS pin_hash TEXT;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS daily_limit NUMERIC;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS monthly_limit NUMERIC;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'active' NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS block_reason TEXT;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS issued_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS activated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE NOT NULL;

-- =============================================
-- TABLE: investments
-- =============================================
CREATE TABLE IF NOT EXISTS investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE investments ADD COLUMN IF NOT EXISTS investment_reference VARCHAR NOT NULL UNIQUE;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS initiated_by_user_id UUID;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS approved_by_user_id UUID;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS pending_action_id UUID;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS goal_name VARCHAR NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS investment_type VARCHAR NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS target_amount NUMERIC NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS current_value NUMERIC NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS lock_period_months INTEGER NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS roi_percentage NUMERIC NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS projected_value NUMERIC NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS transaction_id UUID;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending' NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS activated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS matured_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS withdrawn_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS plan VARCHAR DEFAULT 'starter';
ALTER TABLE investments ADD COLUMN IF NOT EXISTS multiplier NUMERIC DEFAULT 20.00;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS locked_amount NUMERIC DEFAULT 0.00;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS current_profit NUMERIC DEFAULT 0.00;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS lock_months INTEGER DEFAULT 3;
ALTER TABLE investments ADD COLUMN IF NOT EXISTS top_ups NUMERIC DEFAULT 0.00;

-- =============================================
-- TABLE: joint_accounts
-- =============================================
CREATE TABLE IF NOT EXISTS joint_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS primary_user_id UUID;
ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS secondary_user_id UUID;
ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS account_name VARCHAR;
ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending';
ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS invitation_otp VARCHAR NOT NULL;
ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE joint_accounts ADD COLUMN IF NOT EXISTS activated_at TIMESTAMP WITH TIME ZONE;

-- =============================================
-- TABLE: kyc_levels
-- =============================================
CREATE TABLE IF NOT EXISTS kyc_levels (
    id INTEGER PRIMARY KEY
);

ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS level_name VARCHAR NOT NULL;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS fee_amount NUMERIC NOT NULL;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS daily_transfer_limit NUMERIC NOT NULL;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS monthly_transfer_limit NUMERIC NOT NULL;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS can_invest BOOLEAN DEFAULT false;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS can_apply_loan BOOLEAN DEFAULT false;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS can_apply_card BOOLEAN DEFAULT false;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE kyc_levels ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- =============================================
-- TABLE: loan_applications
-- =============================================
CREATE TABLE IF NOT EXISTS loan_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS application_reference VARCHAR NOT NULL UNIQUE;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS initiated_by_user_id UUID;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS approved_by_user_id UUID;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS pending_action_id UUID;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS loan_type VARCHAR NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS amount NUMERIC NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS purpose TEXT NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS term_months INTEGER NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS annual_income NUMERIC;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS employment_status VARCHAR;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS credit_score INTEGER;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS existing_loans NUMERIC DEFAULT 0;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS interest_rate NUMERIC;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS monthly_payment NUMERIC;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS total_repayment NUMERIC;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS transaction_id UUID;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending' NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS admin_notes TEXT;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS disbursed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS total_repayable NUMERIC;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS disbursement_wallet VARCHAR DEFAULT 'usd';
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS crypto_coin VARCHAR;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS repaid BOOLEAN DEFAULT false;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS repaid_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE loan_applications ADD COLUMN IF NOT EXISTS amount_repaid NUMERIC DEFAULT 0.00;

-- =============================================
-- TABLE: loans
-- =============================================
CREATE TABLE IF NOT EXISTS loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE loans ADD COLUMN IF NOT EXISTS loan_reference VARCHAR NOT NULL UNIQUE;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS application_id UUID;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS loan_type VARCHAR NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS principal_amount NUMERIC NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS remaining_balance NUMERIC NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS interest_rate NUMERIC NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS term_months INTEGER NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS monthly_payment NUMERIC NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS next_payment_date DATE;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS next_payment_amount NUMERIC;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS payments_made INTEGER DEFAULT 0 NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS payments_remaining INTEGER NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'active' NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS disbursed_at TIMESTAMP WITH TIME ZONE NOT NULL;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS first_payment_date DATE;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS last_payment_date DATE;
ALTER TABLE loans ADD COLUMN IF NOT EXISTS closed_at TIMESTAMP WITH TIME ZONE;

-- =============================================
-- TABLE: money_requests
-- =============================================
CREATE TABLE IF NOT EXISTS money_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE money_requests ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE money_requests ADD COLUMN IF NOT EXISTS requester_email TEXT;
ALTER TABLE money_requests ADD COLUMN IF NOT EXISTS amount NUMERIC;
ALTER TABLE money_requests ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE money_requests ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending';
ALTER TABLE money_requests ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- =============================================
-- TABLE: notifications
-- =============================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE notifications ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS title TEXT NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS body TEXT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS type VARCHAR DEFAULT 'info';
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- =============================================
-- TABLE: password_reset_tokens
-- =============================================
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE password_reset_tokens ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE password_reset_tokens ADD COLUMN IF NOT EXISTS token VARCHAR NOT NULL UNIQUE;
ALTER TABLE password_reset_tokens ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE NOT NULL;
ALTER TABLE password_reset_tokens ADD COLUMN IF NOT EXISTS used BOOLEAN DEFAULT false;
ALTER TABLE password_reset_tokens ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- =============================================
-- TABLE: pending_actions
-- =============================================
CREATE TABLE IF NOT EXISTS pending_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS joint_account_id UUID NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS initiated_by_user_id UUID NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS action_type VARCHAR NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS action_data JSONB NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending' NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS initiated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE NOT NULL;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS approved_by_user_id UUID;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS rejected_by_user_id UUID;
ALTER TABLE pending_actions ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- =============================================
-- TABLE: sessions
-- =============================================
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE sessions ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE NOT NULL;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS factor_id UUID;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS aal VARCHAR;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS not_after TIMESTAMP WITH TIME ZONE;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS refreshed_at TIMESTAMP WITHOUT TIME ZONE;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS user_agent TEXT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS ip INET;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS tag TEXT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS oauth_client_id UUID;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS refresh_token_hmac_key TEXT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS refresh_token_counter BIGINT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS scopes TEXT;

-- =============================================
-- TABLE: transactions
-- =============================================
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

ALTER TABLE transactions ADD COLUMN IF NOT EXISTS transaction_reference VARCHAR NOT NULL UNIQUE;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS joint_account_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS initiated_by_user_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS approved_by_user_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS pending_action_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS transaction_type VARCHAR NOT NULL;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS amount NUMERIC NOT NULL;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS currency VARCHAR DEFAULT 'USD' NOT NULL;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS from_account_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS to_account_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS from_user_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS to_user_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS from_email VARCHAR;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS to_email VARCHAR;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS metadata JSONB;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'pending' NOT NULL;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS requires_approval BOOLEAN DEFAULT false;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS approval_level VARCHAR;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS failed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS failure_reason TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS beneficiary_id UUID;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS fee NUMERIC DEFAULT 0.00;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS total_amount NUMERIC;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS exchange_rate NUMERIC DEFAULT 1.0000;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS estimated_delivery TIMESTAMP WITH TIME ZONE;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS notification_sent BOOLEAN DEFAULT false;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS crypto_coin VARCHAR;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS crypto_amount NUMERIC;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS crypto_address TEXT;

-- =============================================
-- TABLE: bank_settings
-- =============================================
CREATE TABLE IF NOT EXISTS bank_settings (
    setting_key VARCHAR PRIMARY KEY
);

ALTER TABLE bank_settings ADD COLUMN IF NOT EXISTS setting_value JSONB NOT NULL;
ALTER TABLE bank_settings ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now();
ALTER TABLE bank_settings ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- =============================================
-- VIEWS (3)
-- =============================================

-- =============================================
-- VIEW: card_slots (UNRESTRICTED - RLS DISABLED)
-- =============================================
DROP VIEW IF EXISTS card_slots CASCADE;
CREATE VIEW card_slots AS
SELECT 
    COALESCE((user_id)::text, (joint_account_id)::text) AS account_key,
    user_id,
    joint_account_id,
    SUM(
        CASE
            WHEN (((wallet_type)::text = 'usd'::text) AND ((delivery_type)::text = 'digital'::text) AND ((status)::text <> ALL ((ARRAY['rejected'::character varying, 'cancelled'::character varying])::text[]))) THEN 1
            ELSE 0
        END
    ) AS usd_digital,
    SUM(
        CASE
            WHEN (((wallet_type)::text = 'usd'::text) AND ((delivery_type)::text = 'physical'::text) AND ((status)::text <> ALL ((ARRAY['rejected'::character varying, 'cancelled'::character varying])::text[]))) THEN 1
            ELSE 0
        END
    ) AS usd_physical,
    SUM(
        CASE
            WHEN (((wallet_type)::text = 'crypto'::text) AND ((delivery_type)::text = 'digital'::text) AND ((status)::text <> ALL ((ARRAY['rejected'::character varying, 'cancelled'::character varying])::text[]))) THEN 1
            ELSE 0
        END
    ) AS crypto_digital,
    SUM(
        CASE
            WHEN (((wallet_type)::text = 'crypto'::text) AND ((delivery_type)::text = 'physical'::text) AND ((status)::text <> ALL ((ARRAY['rejected'::character varying, 'cancelled'::character varying])::text[]))) THEN 1
            ELSE 0
        END
    ) AS crypto_physical
FROM 
    card_applications
GROUP BY 
    user_id, 
    joint_account_id;

-- =============================================
-- VIEW: transaction_summary (UNRESTRICTED - RLS DISABLED)
-- =============================================
DROP VIEW IF EXISTS transaction_summary CASCADE;
CREATE VIEW transaction_summary AS
SELECT 
    t.id,
    t.transaction_reference,
    t.transaction_type,
    t.amount,
    t.fee,
    t.total_amount,
    t.currency,
    t.status,
    t.description,
    t.created_at,
    t.completed_at,
    t.estimated_delivery,
    t.metadata,
    t.beneficiary_id,
    b.account_name AS beneficiary_name,
    b.bank_name AS beneficiary_bank,
    b.account_number AS beneficiary_account,
    b.is_us_bank AS beneficiary_is_us,
    CASE
        WHEN (t.joint_account_id IS NOT NULL) THEN 'joint'::text
        ELSE 'individual'::text
    END AS account_type,
    u.email AS user_email,
    (((u.first_name)::text || ' '::text) || (u.last_name)::text) AS user_full_name
FROM 
    transactions t
LEFT JOIN 
    beneficiaries b ON (b.id = t.beneficiary_id)
LEFT JOIN 
    users u ON ((u.id = t.user_id) OR ((t.joint_account_id IS NOT NULL) AND (u.joint_account_id = t.joint_account_id)));

-- =============================================
-- VIEW: user_transactions_view (UNRESTRICTED - RLS DISABLED)
-- =============================================
-- Note: This view was not found in the database. 
-- Please create it based on your requirements.
-- Example structure:
/*
DROP VIEW IF EXISTS user_transactions_view CASCADE;
CREATE VIEW user_transactions_view AS
SELECT 
    ut.id,
    ut.user_id,
    ut.transaction_id,
    ut.relationship_type,
    ut.amount,
    ut.balance_after,
    ut.created_at,
    t.transaction_reference,
    t.transaction_type,
    t.status AS transaction_status,
    t.currency,
    t.description
FROM 
    user_transactions ut
LEFT JOIN 
    transactions t ON t.id = ut.transaction_id;
*/

-- =============================================
-- FOREIGN KEY CONSTRAINTS
-- =============================================

-- users foreign keys
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_joint_account_id_fkey;
ALTER TABLE users ADD CONSTRAINT users_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_kyc_level_fkey;
ALTER TABLE users ADD CONSTRAINT users_kyc_level_fkey 
    FOREIGN KEY (kyc_level) REFERENCES kyc_levels(id);

-- accounts foreign keys
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_user_id_fkey;
ALTER TABLE accounts ADD CONSTRAINT accounts_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_joint_account_id_fkey;
ALTER TABLE accounts ADD CONSTRAINT accounts_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

-- admin_notifications foreign keys
ALTER TABLE admin_notifications DROP CONSTRAINT IF EXISTS admin_notifications_user_id_fkey;
ALTER TABLE admin_notifications ADD CONSTRAINT admin_notifications_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE admin_notifications DROP CONSTRAINT IF EXISTS admin_notifications_joint_account_id_fkey;
ALTER TABLE admin_notifications ADD CONSTRAINT admin_notifications_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

-- admin_review_queue foreign keys
ALTER TABLE admin_review_queue DROP CONSTRAINT IF EXISTS admin_review_queue_user_id_fkey;
ALTER TABLE admin_review_queue ADD CONSTRAINT admin_review_queue_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE admin_review_queue DROP CONSTRAINT IF EXISTS admin_review_queue_joint_account_id_fkey;
ALTER TABLE admin_review_queue ADD CONSTRAINT admin_review_queue_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE admin_review_queue DROP CONSTRAINT IF EXISTS admin_review_queue_assigned_to_fkey;
ALTER TABLE admin_review_queue ADD CONSTRAINT admin_review_queue_assigned_to_fkey 
    FOREIGN KEY (assigned_to) REFERENCES users(id);

ALTER TABLE admin_review_queue DROP CONSTRAINT IF EXISTS admin_review_queue_approved_by_fkey;
ALTER TABLE admin_review_queue ADD CONSTRAINT admin_review_queue_approved_by_fkey 
    FOREIGN KEY (approved_by) REFERENCES users(id);

-- beneficiaries foreign keys
ALTER TABLE beneficiaries DROP CONSTRAINT IF EXISTS beneficiaries_user_id_fkey;
ALTER TABLE beneficiaries ADD CONSTRAINT beneficiaries_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

-- card_applications foreign keys
ALTER TABLE card_applications DROP CONSTRAINT IF EXISTS card_applications_user_id_fkey;
ALTER TABLE card_applications ADD CONSTRAINT card_applications_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE card_applications DROP CONSTRAINT IF EXISTS card_applications_joint_account_id_fkey;
ALTER TABLE card_applications ADD CONSTRAINT card_applications_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE card_applications DROP CONSTRAINT IF EXISTS card_applications_initiated_by_user_id_fkey;
ALTER TABLE card_applications ADD CONSTRAINT card_applications_initiated_by_user_id_fkey 
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id);

ALTER TABLE card_applications DROP CONSTRAINT IF EXISTS card_applications_approved_by_user_id_fkey;
ALTER TABLE card_applications ADD CONSTRAINT card_applications_approved_by_user_id_fkey 
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id);

ALTER TABLE card_applications DROP CONSTRAINT IF EXISTS card_applications_pending_action_id_fkey;
ALTER TABLE card_applications ADD CONSTRAINT card_applications_pending_action_id_fkey 
    FOREIGN KEY (pending_action_id) REFERENCES pending_actions(id);

ALTER TABLE card_applications DROP CONSTRAINT IF EXISTS card_applications_transaction_id_fkey;
ALTER TABLE card_applications ADD CONSTRAINT card_applications_transaction_id_fkey 
    FOREIGN KEY (transaction_id) REFERENCES transactions(id);

-- cards foreign keys
ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_user_id_fkey;
ALTER TABLE cards ADD CONSTRAINT cards_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_joint_account_id_fkey;
ALTER TABLE cards ADD CONSTRAINT cards_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_application_id_fkey;
ALTER TABLE cards ADD CONSTRAINT cards_application_id_fkey 
    FOREIGN KEY (application_id) REFERENCES card_applications(id);

-- investments foreign keys
ALTER TABLE investments DROP CONSTRAINT IF EXISTS investments_user_id_fkey;
ALTER TABLE investments ADD CONSTRAINT investments_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE investments DROP CONSTRAINT IF EXISTS investments_joint_account_id_fkey;
ALTER TABLE investments ADD CONSTRAINT investments_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE investments DROP CONSTRAINT IF EXISTS investments_initiated_by_user_id_fkey;
ALTER TABLE investments ADD CONSTRAINT investments_initiated_by_user_id_fkey 
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id);

ALTER TABLE investments DROP CONSTRAINT IF EXISTS investments_approved_by_user_id_fkey;
ALTER TABLE investments ADD CONSTRAINT investments_approved_by_user_id_fkey 
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id);

ALTER TABLE investments DROP CONSTRAINT IF EXISTS investments_pending_action_id_fkey;
ALTER TABLE investments ADD CONSTRAINT investments_pending_action_id_fkey 
    FOREIGN KEY (pending_action_id) REFERENCES pending_actions(id);

ALTER TABLE investments DROP CONSTRAINT IF EXISTS investments_transaction_id_fkey;
ALTER TABLE investments ADD CONSTRAINT investments_transaction_id_fkey 
    FOREIGN KEY (transaction_id) REFERENCES transactions(id);

-- joint_accounts foreign keys
ALTER TABLE joint_accounts DROP CONSTRAINT IF EXISTS joint_accounts_primary_user_id_fkey;
ALTER TABLE joint_accounts ADD CONSTRAINT joint_accounts_primary_user_id_fkey 
    FOREIGN KEY (primary_user_id) REFERENCES users(id);

ALTER TABLE joint_accounts DROP CONSTRAINT IF EXISTS joint_accounts_secondary_user_id_fkey;
ALTER TABLE joint_accounts ADD CONSTRAINT joint_accounts_secondary_user_id_fkey 
    FOREIGN KEY (secondary_user_id) REFERENCES users(id);

-- loan_applications foreign keys
ALTER TABLE loan_applications DROP CONSTRAINT IF EXISTS loan_applications_user_id_fkey;
ALTER TABLE loan_applications ADD CONSTRAINT loan_applications_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE loan_applications DROP CONSTRAINT IF EXISTS loan_applications_joint_account_id_fkey;
ALTER TABLE loan_applications ADD CONSTRAINT loan_applications_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE loan_applications DROP CONSTRAINT IF EXISTS loan_applications_initiated_by_user_id_fkey;
ALTER TABLE loan_applications ADD CONSTRAINT loan_applications_initiated_by_user_id_fkey 
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id);

ALTER TABLE loan_applications DROP CONSTRAINT IF EXISTS loan_applications_approved_by_user_id_fkey;
ALTER TABLE loan_applications ADD CONSTRAINT loan_applications_approved_by_user_id_fkey 
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id);

ALTER TABLE loan_applications DROP CONSTRAINT IF EXISTS loan_applications_pending_action_id_fkey;
ALTER TABLE loan_applications ADD CONSTRAINT loan_applications_pending_action_id_fkey 
    FOREIGN KEY (pending_action_id) REFERENCES pending_actions(id);

ALTER TABLE loan_applications DROP CONSTRAINT IF EXISTS loan_applications_transaction_id_fkey;
ALTER TABLE loan_applications ADD CONSTRAINT loan_applications_transaction_id_fkey 
    FOREIGN KEY (transaction_id) REFERENCES transactions(id);

-- loans foreign keys
ALTER TABLE loans DROP CONSTRAINT IF EXISTS loans_application_id_fkey;
ALTER TABLE loans ADD CONSTRAINT loans_application_id_fkey 
    FOREIGN KEY (application_id) REFERENCES loan_applications(id);

ALTER TABLE loans DROP CONSTRAINT IF EXISTS loans_user_id_fkey;
ALTER TABLE loans ADD CONSTRAINT loans_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE loans DROP CONSTRAINT IF EXISTS loans_joint_account_id_fkey;
ALTER TABLE loans ADD CONSTRAINT loans_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

-- money_requests foreign keys
ALTER TABLE money_requests DROP CONSTRAINT IF EXISTS money_requests_user_id_fkey;
ALTER TABLE money_requests ADD CONSTRAINT money_requests_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

-- notifications foreign keys
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_joint_account_id_fkey;
ALTER TABLE notifications ADD CONSTRAINT notifications_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

-- password_reset_tokens foreign keys
ALTER TABLE password_reset_tokens DROP CONSTRAINT IF EXISTS password_reset_tokens_user_id_fkey;
ALTER TABLE password_reset_tokens ADD CONSTRAINT password_reset_tokens_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

-- pending_actions foreign keys
ALTER TABLE pending_actions DROP CONSTRAINT IF EXISTS pending_actions_joint_account_id_fkey;
ALTER TABLE pending_actions ADD CONSTRAINT pending_actions_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE pending_actions DROP CONSTRAINT IF EXISTS pending_actions_initiated_by_user_id_fkey;
ALTER TABLE pending_actions ADD CONSTRAINT pending_actions_initiated_by_user_id_fkey 
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id);

ALTER TABLE pending_actions DROP CONSTRAINT IF EXISTS pending_actions_approved_by_user_id_fkey;
ALTER TABLE pending_actions ADD CONSTRAINT pending_actions_approved_by_user_id_fkey 
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id);

ALTER TABLE pending_actions DROP CONSTRAINT IF EXISTS pending_actions_rejected_by_user_id_fkey;
ALTER TABLE pending_actions ADD CONSTRAINT pending_actions_rejected_by_user_id_fkey 
    FOREIGN KEY (rejected_by_user_id) REFERENCES users(id);

-- sessions foreign keys
ALTER TABLE sessions DROP CONSTRAINT IF EXISTS sessions_user_id_fkey;
ALTER TABLE sessions ADD CONSTRAINT sessions_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

-- transactions foreign keys
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_user_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_joint_account_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_joint_account_id_fkey 
    FOREIGN KEY (joint_account_id) REFERENCES joint_accounts(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_initiated_by_user_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_initiated_by_user_id_fkey 
    FOREIGN KEY (initiated_by_user_id) REFERENCES users(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_approved_by_user_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_approved_by_user_id_fkey 
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_pending_action_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_pending_action_id_fkey 
    FOREIGN KEY (pending_action_id) REFERENCES pending_actions(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_from_account_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_from_account_fkey 
    FOREIGN KEY (from_account_id) REFERENCES accounts(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_to_account_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_to_account_fkey 
    FOREIGN KEY (to_account_id) REFERENCES accounts(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_from_user_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_from_user_id_fkey 
    FOREIGN KEY (from_user_id) REFERENCES users(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_to_user_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_to_user_id_fkey 
    FOREIGN KEY (to_user_id) REFERENCES users(id);

ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_beneficiary_id_fkey;
ALTER TABLE transactions ADD CONSTRAINT transactions_beneficiary_id_fkey 
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_review_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE beneficiaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE investments ENABLE ROW LEVEL SECURITY;
ALTER TABLE joint_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE loan_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE money_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE pending_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_settings ENABLE ROW LEVEL SECURITY;

-- Tables marked as UNRESTRICTED have RLS DISABLED
-- admin_notifications - RLS DISABLED
-- kyc_levels - RLS DISABLED

-- =============================================
-- RLS POLICIES
-- =============================================

-- accounts policies
DROP POLICY IF EXISTS "Allow insert based on user_id" ON accounts;
CREATE POLICY "Allow insert based on user_id" ON accounts
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow select based on user_id" ON accounts;
CREATE POLICY "Allow select based on user_id" ON accounts
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow update based on user_id" ON accounts;
CREATE POLICY "Allow update based on user_id" ON accounts
    FOR UPDATE USING (true) WITH CHECK (true);

-- admin_review_queue policies
DROP POLICY IF EXISTS "admin_review_queue_all" ON admin_review_queue;
CREATE POLICY "admin_review_queue_all" ON admin_review_queue
    FOR ALL USING (true) WITH CHECK (true);

-- beneficiaries policies
DROP POLICY IF EXISTS "beneficiaries_all" ON beneficiaries;
CREATE POLICY "beneficiaries_all" ON beneficiaries
    FOR ALL USING (true) WITH CHECK (true);

-- card_applications policies
DROP POLICY IF EXISTS "card_apps_all" ON card_applications;
CREATE POLICY "card_apps_all" ON card_applications
    FOR ALL USING (true) WITH CHECK (true);

-- cards policies
DROP POLICY IF EXISTS "cards_all" ON cards;
CREATE POLICY "cards_all" ON cards
    FOR ALL USING (true) WITH CHECK (true);

-- investments policies
DROP POLICY IF EXISTS "investments_all" ON investments;
CREATE POLICY "investments_all" ON investments
    FOR ALL USING (true) WITH CHECK (true);

-- joint_accounts policies
DROP POLICY IF EXISTS "Anyone can create joint accounts" ON joint_accounts;
CREATE POLICY "Anyone can create joint accounts" ON joint_accounts
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Joint account members can view" ON joint_accounts;
CREATE POLICY "Joint account members can view" ON joint_accounts
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Joint account members can update" ON joint_accounts;
CREATE POLICY "Joint account members can update" ON joint_accounts
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "joint_accounts_all" ON joint_accounts;
CREATE POLICY "joint_accounts_all" ON joint_accounts
    FOR ALL USING (true) WITH CHECK (true);

-- loan_applications policies
DROP POLICY IF EXISTS "loan_apps_all" ON loan_applications;
CREATE POLICY "loan_apps_all" ON loan_applications
    FOR ALL USING (true) WITH CHECK (true);

-- loans policies
DROP POLICY IF EXISTS "loans_all" ON loans;
CREATE POLICY "loans_all" ON loans
    FOR ALL USING (true) WITH CHECK (true);

-- money_requests policies
DROP POLICY IF EXISTS "money_requests_all" ON money_requests;
CREATE POLICY "money_requests_all" ON money_requests
    FOR ALL USING (true) WITH CHECK (true);

-- notifications policies
DROP POLICY IF EXISTS "notifications_all" ON notifications;
CREATE POLICY "notifications_all" ON notifications
    FOR ALL USING (true) WITH CHECK (true);

-- password_reset_tokens policies
DROP POLICY IF EXISTS "Reset tokens can be created" ON password_reset_tokens;
CREATE POLICY "Reset tokens can be created" ON password_reset_tokens
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Reset tokens can be read during recovery" ON password_reset_tokens;
CREATE POLICY "Reset tokens can be read during recovery" ON password_reset_tokens
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can view own reset tokens" ON password_reset_tokens;
CREATE POLICY "Users can view own reset tokens" ON password_reset_tokens
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "prt_all" ON password_reset_tokens;
CREATE POLICY "prt_all" ON password_reset_tokens
    FOR ALL USING (true) WITH CHECK (true);

-- pending_actions policies
DROP POLICY IF EXISTS "pending_actions_all" ON pending_actions;
CREATE POLICY "pending_actions_all" ON pending_actions
    FOR ALL USING (true) WITH CHECK (true);

-- sessions policies
DROP POLICY IF EXISTS "Allow delete sessions" ON sessions;
CREATE POLICY "Allow delete sessions" ON sessions
    FOR DELETE USING (true);

DROP POLICY IF EXISTS "Allow insert sessions" ON sessions;
CREATE POLICY "Allow insert sessions" ON sessions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow select sessions" ON sessions;
CREATE POLICY "Allow select sessions" ON sessions
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow update sessions" ON sessions;
CREATE POLICY "Allow update sessions" ON sessions
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "sessions_delete" ON sessions;
CREATE POLICY "sessions_delete" ON sessions
    FOR DELETE USING (true);

DROP POLICY IF EXISTS "sessions_insert" ON sessions;
CREATE POLICY "sessions_insert" ON sessions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "sessions_select" ON sessions;
CREATE POLICY "sessions_select" ON sessions
    FOR SELECT USING (true);

-- transactions policies
DROP POLICY IF EXISTS "transactions_all" ON transactions;
CREATE POLICY "transactions_all" ON transactions
    FOR ALL USING (true) WITH CHECK (true);

-- users policies
DROP POLICY IF EXISTS "Allow insert users" ON users;
CREATE POLICY "Allow insert users" ON users
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow select users" ON users;
CREATE POLICY "Allow select users" ON users
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow update users" ON users;
CREATE POLICY "Allow update users" ON users
    FOR UPDATE USING (true) WITH CHECK (true);

-- bank_settings policies
DROP POLICY IF EXISTS "bank_settings_all" ON bank_settings;
CREATE POLICY "bank_settings_all" ON bank_settings
    FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_joint_account_id ON users(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_users_kyc_level ON users(kyc_level);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);

-- accounts indexes
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_joint_account_id ON accounts(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_accounts_account_number ON accounts(account_number);

-- admin_notifications indexes
CREATE INDEX IF NOT EXISTS idx_admin_notifications_user_id ON admin_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_joint_account_id ON admin_notifications(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_created_at ON admin_notifications(created_at);

-- admin_review_queue indexes
CREATE INDEX IF NOT EXISTS idx_admin_review_queue_user_id ON admin_review_queue(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_review_queue_status ON admin_review_queue(status);
CREATE INDEX IF NOT EXISTS idx_admin_review_queue_created_at ON admin_review_queue(created_at);

-- beneficiaries indexes
CREATE INDEX IF NOT EXISTS idx_beneficiaries_user_id ON beneficiaries(user_id);
CREATE INDEX IF NOT EXISTS idx_beneficiaries_beneficiary_reference ON beneficiaries(beneficiary_reference);

-- card_applications indexes
CREATE INDEX IF NOT EXISTS idx_card_applications_user_id ON card_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_card_applications_status ON card_applications(status);

-- cards indexes
CREATE INDEX IF NOT EXISTS idx_cards_user_id ON cards(user_id);
CREATE INDEX IF NOT EXISTS idx_cards_joint_account_id ON cards(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_cards_status ON cards(status);
CREATE INDEX IF NOT EXISTS idx_cards_card_number_hash ON cards(card_number_hash);

-- investments indexes
CREATE INDEX IF NOT EXISTS idx_investments_user_id ON investments(user_id);
CREATE INDEX IF NOT EXISTS idx_investments_joint_account_id ON investments(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_investments_status ON investments(status);

-- joint_accounts indexes
CREATE INDEX IF NOT EXISTS idx_joint_accounts_primary_user_id ON joint_accounts(primary_user_id);
CREATE INDEX IF NOT EXISTS idx_joint_accounts_secondary_user_id ON joint_accounts(secondary_user_id);

-- loan_applications indexes
CREATE INDEX IF NOT EXISTS idx_loan_applications_user_id ON loan_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_loan_applications_status ON loan_applications(status);

-- loans indexes
CREATE INDEX IF NOT EXISTS idx_loans_user_id ON loans(user_id);
CREATE INDEX IF NOT EXISTS idx_loans_joint_account_id ON loans(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_loans_status ON loans(status);

-- notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_joint_account_id ON notifications(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- pending_actions indexes
CREATE INDEX IF NOT EXISTS idx_pending_actions_joint_account_id ON pending_actions(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_pending_actions_status ON pending_actions(status);
CREATE INDEX IF NOT EXISTS idx_pending_actions_expires_at ON pending_actions(expires_at);

-- sessions indexes
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);

-- transactions indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_joint_account_id ON transactions(joint_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_reference ON transactions(transaction_reference);
CREATE INDEX IF NOT EXISTS idx_transactions_from_account_id ON transactions(from_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_to_account_id ON transactions(to_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_beneficiary_id ON transactions(beneficiary_id);

-- =============================================
-- TRIGGERS FOR updated_at
-- =============================================

-- =============================================
-- ADMINISTRATIVE FUNCTIONS (SECURITY DEFINER)
-- =============================================

CREATE OR REPLACE FUNCTION admin_delete_record(target_table TEXT, target_id TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    caller_role VARCHAR;
    target_uuid UUID;
BEGIN
    target_uuid := target_id::UUID;

    -- 1. Check if caller is authenticated and has admin role
    SELECT role INTO caller_role FROM users WHERE id = auth.uid();
    IF caller_role IS NULL THEN
        SELECT role INTO caller_role FROM users WHERE LOWER(email) = LOWER(auth.jwt() ->> 'email');
    END IF;

    IF caller_role IS NULL OR caller_role != 'admin' THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can perform deletions (uid: %, email: %)', COALESCE(auth.uid()::text, 'none'), COALESCE(auth.jwt() ->> 'email', 'none');
    END IF;

    -- 2. Execute deletion dynamically based on table name
    IF target_table = 'accounts' THEN
        DELETE FROM transactions WHERE from_account_id = target_uuid OR to_account_id = target_uuid;
        DELETE FROM accounts WHERE id = target_uuid;
    ELSIF target_table = 'joint_accounts' THEN
        DELETE FROM transactions WHERE joint_account_id = target_uuid;
        DELETE FROM accounts WHERE joint_account_id = target_uuid;
        DELETE FROM users WHERE joint_account_id = target_uuid;
        DELETE FROM joint_accounts WHERE id = target_uuid;
    ELSIF target_table = 'users' THEN
        DELETE FROM sessions WHERE user_id = target_uuid;
        DELETE FROM password_reset_tokens WHERE user_id = target_uuid;
        DELETE FROM notifications WHERE user_id = target_uuid;
        DELETE FROM admin_notifications WHERE user_id = target_uuid;
        DELETE FROM beneficiaries WHERE user_id = target_uuid;
        DELETE FROM card_applications WHERE user_id = target_uuid;
        DELETE FROM cards WHERE user_id = target_uuid;
        DELETE FROM investments WHERE user_id = target_uuid;
        DELETE FROM loans WHERE user_id = target_uuid;
        DELETE FROM loan_applications WHERE user_id = target_uuid;
        DELETE FROM transactions WHERE user_id = target_uuid OR from_user_id = target_uuid OR to_user_id = target_uuid OR initiated_by_user_id = target_uuid OR approved_by_user_id = target_uuid;
        DELETE FROM pending_actions WHERE initiated_by_user_id = target_uuid OR approved_by_user_id = target_uuid OR rejected_by_user_id = target_uuid;
        DELETE FROM admin_review_queue WHERE user_id = target_uuid OR assigned_to = target_uuid OR approved_by = target_uuid;
        DELETE FROM money_requests WHERE user_id = target_uuid;
        DELETE FROM accounts WHERE user_id = target_uuid;
        DELETE FROM users WHERE id = target_uuid;
    ELSIF target_table = 'transactions' THEN
        DELETE FROM transactions WHERE id = target_uuid;
    ELSIF target_table = 'card_applications' THEN
        DELETE FROM card_applications WHERE id = target_uuid;
    ELSIF target_table = 'loan_applications' THEN
        DELETE FROM loan_applications WHERE id = target_uuid;
    ELSIF target_table = 'investments' THEN
        DELETE FROM investments WHERE id = target_uuid;
    ELSIF target_table = 'notifications' THEN
        DELETE FROM notifications WHERE id = target_uuid;
    ELSE
        RAISE EXCEPTION 'Invalid table name';
    END IF;
END;
$$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_accounts_updated_at ON accounts;
CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_beneficiaries_updated_at ON beneficiaries;
CREATE TRIGGER update_beneficiaries_updated_at BEFORE UPDATE ON beneficiaries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_card_applications_updated_at ON card_applications;
CREATE TRIGGER update_card_applications_updated_at BEFORE UPDATE ON card_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_investments_updated_at ON investments;
CREATE TRIGGER update_investments_updated_at BEFORE UPDATE ON investments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_loan_applications_updated_at ON loan_applications;
CREATE TRIGGER update_loan_applications_updated_at BEFORE UPDATE ON loan_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_transactions_updated_at ON transactions;
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_bank_settings_updated_at ON bank_settings;
CREATE TRIGGER update_bank_settings_updated_at BEFORE UPDATE ON bank_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- INITIAL DATA (KYC Levels - UNRESTRICTED)
-- =============================================

INSERT INTO kyc_levels (id, level_name, fee_amount, daily_transfer_limit, monthly_transfer_limit, can_invest, can_apply_loan, can_apply_card, description) VALUES
(1, 'Basic', 0.00, 1000.00, 10000.00, false, false, false, 'Basic KYC level with limited features'),
(2, 'Verified', 10.00, 5000.00, 50000.00, true, false, false, 'Verified KYC level with investment access'),
(3, 'Premium', 25.00, 10000.00, 100000.00, true, true, false, 'Premium KYC level with loan access'),
(4, 'Enterprise', 50.00, 25000.00, 250000.00, true, true, true, 'Enterprise KYC level with full access')
ON CONFLICT (id) DO NOTHING;

INSERT INTO bank_settings (setting_key, setting_value) VALUES
('exchange_rates', '{"ZAR": 18.80, "BWP": 13.50, "MXN": 17.00, "PHP": 56.00, "ARS": 850.00, "COP": 3900.00, "CLP": 950.00}'::jsonb)
ON CONFLICT (setting_key) DO NOTHING;
