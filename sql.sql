-- ================================================================
-- West Haven Bank — COMPLETE DATABASE RECREATION SCRIPT
-- Source: live Supabase schema export
-- Run top-to-bottom in Supabase SQL Editor.
-- Tables are ordered to satisfy all foreign key dependencies.
-- ================================================================


-- ── EXTENSIONS ───────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ================================================================
-- 1. USERS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.users (
    id                    uuid           PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    email                 varchar(255)   NOT NULL UNIQUE,
    password_hash         text           NOT NULL,
    first_name            varchar(100)   NOT NULL,
    last_name             varchar(100)   NOT NULL,
    birth_date            date           NOT NULL,
    gender                varchar(20)    DEFAULT NULL,
    country               varchar(100)   NOT NULL,
    government_id_url     text           DEFAULT NULL,
    profile_picture_url   text           DEFAULT NULL,
    recovery_phrase_hash  text           NOT NULL,
    transaction_pin_hash  text           DEFAULT NULL,
    account_type          varchar(20)    NOT NULL,
    joint_account_id      uuid           DEFAULT NULL, -- FK added after joint_accounts
    is_verified           boolean        DEFAULT false,
    otp_code              varchar(10)    DEFAULT NULL,
    otp_expires_at        timestamptz    DEFAULT NULL,
    created_at            timestamptz    DEFAULT now(),
    updated_at            timestamptz    DEFAULT now(),

    CONSTRAINT users_account_type_check CHECK (
        account_type = ANY (ARRAY['individual'::varchar, 'joint'::varchar])
    ),
    CONSTRAINT users_gender_check CHECK (
        gender IS NULL OR gender = ANY (ARRAY[
            'male'::varchar, 'female'::varchar,
            'other'::varchar, 'prefer-not-to-say'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_users_email         ON public.users (email);
CREATE INDEX IF NOT EXISTS idx_users_joint_account ON public.users (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_users_otp           ON public.users (otp_code) WHERE otp_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_recovery      ON public.users (recovery_phrase_hash);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow insert users" ON public.users;
DROP POLICY IF EXISTS "Allow select users" ON public.users;
DROP POLICY IF EXISTS "Allow update users" ON public.users;
CREATE POLICY "Allow insert users" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Allow update users" ON public.users FOR UPDATE USING (true) WITH CHECK (true);


-- ================================================================
-- 2. SESSIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.sessions (
    id             uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id        uuid        REFERENCES public.users(id) ON DELETE CASCADE,
    session_token  varchar(255) NOT NULL UNIQUE,
    expires_at     timestamptz NOT NULL,
    created_at     timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sessions_token   ON public.sessions (session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON public.sessions (expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_user    ON public.sessions (user_id);

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow insert sessions"  ON public.sessions;
DROP POLICY IF EXISTS "Allow select sessions"  ON public.sessions;
DROP POLICY IF EXISTS "Allow update sessions"  ON public.sessions;
DROP POLICY IF EXISTS "Allow delete sessions"  ON public.sessions;
DROP POLICY IF EXISTS "sessions_insert"        ON public.sessions;
DROP POLICY IF EXISTS "sessions_select"        ON public.sessions;
DROP POLICY IF EXISTS "sessions_delete"        ON public.sessions;
CREATE POLICY "Allow insert sessions" ON public.sessions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select sessions" ON public.sessions FOR SELECT USING (true);
CREATE POLICY "Allow update sessions" ON public.sessions FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow delete sessions" ON public.sessions FOR DELETE USING (true);
CREATE POLICY "sessions_insert"       ON public.sessions FOR INSERT WITH CHECK (true);
CREATE POLICY "sessions_select"       ON public.sessions FOR SELECT USING (true);
CREATE POLICY "sessions_delete"       ON public.sessions FOR DELETE USING (true);


-- ================================================================
-- 3. PASSWORD RESET TOKENS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.password_reset_tokens (
    id          uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id     uuid        REFERENCES public.users(id) ON DELETE CASCADE,
    token       varchar(255) NOT NULL UNIQUE,
    expires_at  timestamptz NOT NULL,
    used        boolean     DEFAULT false,
    created_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token   ON public.password_reset_tokens (token);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON public.password_reset_tokens (user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires ON public.password_reset_tokens (expires_at);

ALTER TABLE public.password_reset_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "prt_all"                              ON public.password_reset_tokens;
DROP POLICY IF EXISTS "Reset tokens can be created"          ON public.password_reset_tokens;
DROP POLICY IF EXISTS "Reset tokens can be read during recovery" ON public.password_reset_tokens;
DROP POLICY IF EXISTS "Users can view own reset tokens"      ON public.password_reset_tokens;
CREATE POLICY "prt_all"                               ON public.password_reset_tokens FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Reset tokens can be created"           ON public.password_reset_tokens FOR INSERT WITH CHECK (true);
CREATE POLICY "Reset tokens can be read during recovery" ON public.password_reset_tokens FOR SELECT USING (true);
CREATE POLICY "Users can view own reset tokens"       ON public.password_reset_tokens FOR SELECT USING (true);


-- ================================================================
-- 4. JOINT ACCOUNTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.joint_accounts (
    id                  uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    primary_user_id     uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    secondary_user_id   uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    account_name        varchar(255) DEFAULT NULL,
    status              varchar(20)  DEFAULT 'pending',
    invitation_otp      varchar(10)  NOT NULL,
    created_at          timestamptz  DEFAULT now(),
    activated_at        timestamptz  DEFAULT NULL,

    CONSTRAINT joint_accounts_status_check CHECK (
        status = ANY (ARRAY['pending'::varchar, 'active'::varchar, 'suspended'::varchar])
    )
);

CREATE INDEX IF NOT EXISTS idx_joint_accounts_primary   ON public.joint_accounts (primary_user_id);
CREATE INDEX IF NOT EXISTS idx_joint_accounts_secondary ON public.joint_accounts (secondary_user_id);
CREATE INDEX IF NOT EXISTS idx_joint_accounts_status    ON public.joint_accounts (status);
CREATE INDEX IF NOT EXISTS idx_joint_accounts_otp       ON public.joint_accounts (invitation_otp);

ALTER TABLE public.joint_accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can create joint accounts"  ON public.joint_accounts;
DROP POLICY IF EXISTS "Joint account members can update"  ON public.joint_accounts;
DROP POLICY IF EXISTS "Joint account members can view"    ON public.joint_accounts;
DROP POLICY IF EXISTS "joint_accounts_all"                ON public.joint_accounts;
CREATE POLICY "Anyone can create joint accounts" ON public.joint_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY "Joint account members can update" ON public.joint_accounts FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Joint account members can view"   ON public.joint_accounts FOR SELECT USING (true);
CREATE POLICY "joint_accounts_all"               ON public.joint_accounts FOR ALL USING (true) WITH CHECK (true);

-- Deferred FK: users → joint_accounts
ALTER TABLE public.users
    ADD CONSTRAINT users_joint_account_id_fkey
    FOREIGN KEY (joint_account_id)
    REFERENCES public.joint_accounts(id)
    ON DELETE SET NULL;


-- ================================================================
-- 5. ACCOUNTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.accounts (
    id                   uuid         PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    account_number       varchar(20)  NOT NULL UNIQUE,
    user_id              uuid         REFERENCES public.users(id) ON DELETE CASCADE,
    joint_account_id     uuid         REFERENCES public.joint_accounts(id) ON DELETE CASCADE,
    balance              numeric(15,2) DEFAULT 0.00,
    currency             varchar(3)   DEFAULT 'USD',
    status               varchar(20)  DEFAULT 'active',
    created_at           timestamptz  DEFAULT now(),
    updated_at           timestamptz  DEFAULT now(),

    -- Crypto wallets
    btc_address          text         DEFAULT NULL,
    ltc_address          text         DEFAULT NULL,
    btc_balance          numeric(18,8) DEFAULT 0.00000000,
    ltc_balance          numeric(18,8) DEFAULT 0.00000000,

    -- Gas wallet
    gas_balance          numeric(15,2) DEFAULT 0.00,
    gas_wallet_address   text         DEFAULT NULL,
    gas_wallet_network   varchar(20)  DEFAULT NULL,

    -- Withdrawal control (added via migration)
    allow_withdrawal     boolean      NOT NULL DEFAULT true,
    withdrawal_alert_msg text         DEFAULT NULL,

    CONSTRAINT accounts_status_check CHECK (
        status = ANY (ARRAY['active'::varchar, 'suspended'::varchar, 'closed'::varchar])
    ),
    CONSTRAINT accounts_check CHECK (
        (user_id IS NOT NULL AND joint_account_id IS NULL)
        OR
        (user_id IS NULL AND joint_account_id IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_accounts_user_id          ON public.accounts (user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_joint_account_id ON public.accounts (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_accounts_account_number   ON public.accounts (account_number);
CREATE INDEX IF NOT EXISTS idx_accounts_joint            ON public.accounts (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_accounts_user             ON public.accounts (user_id);

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow insert based on user_id" ON public.accounts;
DROP POLICY IF EXISTS "Allow select based on user_id" ON public.accounts;
DROP POLICY IF EXISTS "Allow update based on user_id" ON public.accounts;
CREATE POLICY "Allow insert based on user_id" ON public.accounts FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select based on user_id" ON public.accounts FOR SELECT USING (true);
CREATE POLICY "Allow update based on user_id" ON public.accounts FOR UPDATE USING (true) WITH CHECK (true);


-- ================================================================
-- 6. ADMIN REVIEW QUEUE
-- Created before transactions so add_to_admin_review_queue() can reference it.
-- ================================================================

CREATE TABLE IF NOT EXISTS public.admin_review_queue (
    id               uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    review_type      varchar(30) NOT NULL,
    reference_id     uuid        NOT NULL,
    reference_table  varchar(50) NOT NULL,
    user_id          uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id uuid        REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    priority         varchar(20) NOT NULL DEFAULT 'medium',
    status           varchar(20) NOT NULL DEFAULT 'pending',
    assigned_to      uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    created_at       timestamptz NOT NULL DEFAULT now(),
    assigned_at      timestamptz DEFAULT NULL,
    reviewed_at      timestamptz DEFAULT NULL,
    review_notes     text        DEFAULT NULL,
    approved_by      uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    approved_at      timestamptz DEFAULT NULL,
    rejection_reason text        DEFAULT NULL,
    rejected_at      timestamptz DEFAULT NULL,

    CONSTRAINT admin_review_queue_priority_check CHECK (
        priority = ANY (ARRAY['low'::varchar, 'medium'::varchar, 'high'::varchar, 'urgent'::varchar])
    ),
    CONSTRAINT admin_review_queue_status_check CHECK (
        status = ANY (ARRAY['pending'::varchar, 'in_review'::varchar, 'approved'::varchar, 'rejected'::varchar])
    )
);

CREATE INDEX IF NOT EXISTS idx_admin_review_queue_status     ON public.admin_review_queue (status);
CREATE INDEX IF NOT EXISTS idx_admin_review_queue_priority   ON public.admin_review_queue (priority);
CREATE INDEX IF NOT EXISTS idx_admin_review_queue_created_at ON public.admin_review_queue (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_review_queue_reference  ON public.admin_review_queue (reference_id, reference_table);

ALTER TABLE public.admin_review_queue ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "admin_review_queue_all" ON public.admin_review_queue;
CREATE POLICY "admin_review_queue_all" ON public.admin_review_queue FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 7. TRIGGER FUNCTIONS
-- All defined before the tables that use them.
-- ================================================================

-- ── generate_transaction_reference ───────────────────────────────

CREATE OR REPLACE FUNCTION public.generate_transaction_reference()
RETURNS TRIGGER AS $$
DECLARE
    ref          text;
    prefix       text;
    exists_check boolean;
BEGIN
    prefix := CASE NEW.transaction_type
        WHEN 'send'                 THEN 'TXN'
        WHEN 'receive'              THEN 'TXN'
        WHEN 'transfer'             THEN 'TXN'
        WHEN 'card_payment'         THEN 'CRD'
        WHEN 'loan_disbursement'    THEN 'LND'
        WHEN 'investment_deposit'   THEN 'INV'
        WHEN 'investment_withdrawal'THEN 'INV'
        WHEN 'crypto_send'          THEN 'CRY'
        WHEN 'crypto_receive'       THEN 'CRY'
        ELSE 'TXN'
    END;
    LOOP
        ref := prefix || '-' || to_char(now(), 'YYYYMMDD') || '-'
            || upper(substring(encode(gen_random_bytes(3), 'hex') FROM 1 FOR 6));
        SELECT EXISTS (
            SELECT 1 FROM public.transactions WHERE transaction_reference = ref
        ) INTO exists_check;
        EXIT WHEN NOT exists_check;
    END LOOP;
    NEW.transaction_reference := ref;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── send_transaction_notification ────────────────────────────────

CREATE OR REPLACE FUNCTION public.send_transaction_notification()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        IF NEW.user_id IS NOT NULL THEN
            INSERT INTO public.notifications (user_id, title, body, type)
            VALUES (
                NEW.user_id,
                'Transaction ' || initcap(NEW.status),
                COALESCE(NEW.description,
                    'Your transaction of $' || NEW.amount || ' is now ' || NEW.status || '.'),
                CASE NEW.status
                    WHEN 'completed'  THEN 'success'
                    WHEN 'failed'     THEN 'error'
                    WHEN 'rejected'   THEN 'error'
                    ELSE 'info'
                END
            );
        END IF;
        IF NEW.joint_account_id IS NOT NULL THEN
            INSERT INTO public.notifications (joint_account_id, title, body, type)
            VALUES (
                NEW.joint_account_id,
                'Transaction ' || initcap(NEW.status),
                COALESCE(NEW.description,
                    'A transaction of $' || NEW.amount || ' is now ' || NEW.status || '.'),
                CASE NEW.status
                    WHEN 'completed'  THEN 'success'
                    WHEN 'failed'     THEN 'error'
                    WHEN 'rejected'   THEN 'error'
                    ELSE 'info'
                END
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── update_beneficiary_usage ──────────────────────────────────────

CREATE OR REPLACE FUNCTION public.update_beneficiary_usage()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.beneficiary_id IS NOT NULL THEN
        UPDATE public.beneficiaries
        SET transfer_count = transfer_count + 1,
            last_used_at   = now(),
            updated_at     = now()
        WHERE id = NEW.beneficiary_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── add_to_admin_review_queue ─────────────────────────────────────

CREATE OR REPLACE FUNCTION public.add_to_admin_review_queue()
RETURNS TRIGGER AS $$
DECLARE
    v_priority text := 'medium';
BEGIN
    IF TG_TABLE_NAME = 'transactions' AND NEW.amount > 50000 THEN
        v_priority := 'high';
    END IF;

    INSERT INTO public.admin_review_queue (
        review_type, reference_id, reference_table,
        user_id, joint_account_id, priority, status
    ) VALUES (
        TG_TABLE_NAME,
        NEW.id,
        TG_TABLE_NAME,
        CASE WHEN TG_TABLE_NAME = 'transactions'
             THEN COALESCE(NEW.user_id, NEW.initiated_by_user_id)
             ELSE NEW.user_id
        END,
        NEW.joint_account_id,
        v_priority,
        'pending'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── generate_card_reference ───────────────────────────────────────

CREATE OR REPLACE FUNCTION public.generate_card_reference()
RETURNS TRIGGER AS $$
DECLARE
    ref          text;
    exists_check boolean;
BEGIN
    LOOP
        ref := 'CARD-' || upper(substring(encode(gen_random_bytes(4), 'hex') FROM 1 FOR 8));
        SELECT EXISTS (
            SELECT 1 FROM public.card_applications WHERE application_reference = ref
        ) INTO exists_check;
        EXIT WHEN NOT exists_check;
    END LOOP;
    NEW.application_reference := ref;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── generate_loan_reference ───────────────────────────────────────

CREATE OR REPLACE FUNCTION public.generate_loan_reference()
RETURNS TRIGGER AS $$
DECLARE
    ref          text;
    exists_check boolean;
BEGIN
    LOOP
        ref := 'LOAN-' || upper(substring(encode(gen_random_bytes(4), 'hex') FROM 1 FOR 8));
        SELECT EXISTS (
            SELECT 1 FROM public.loan_applications WHERE application_reference = ref
        ) INTO exists_check;
        EXIT WHEN NOT exists_check;
    END LOOP;
    NEW.application_reference := ref;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── generate_investment_reference ────────────────────────────────

CREATE OR REPLACE FUNCTION public.generate_investment_reference()
RETURNS TRIGGER AS $$
DECLARE
    ref          text;
    exists_check boolean;
BEGIN
    LOOP
        ref := 'INV-' || to_char(now(), 'YYYYMMDD') || '-'
            || upper(substring(encode(gen_random_bytes(3), 'hex') FROM 1 FOR 6));
        SELECT EXISTS (
            SELECT 1 FROM public.investments WHERE investment_reference = ref
        ) INTO exists_check;
        EXIT WHEN NOT exists_check;
    END LOOP;
    NEW.investment_reference := ref;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ================================================================
-- 8. TRANSACTIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.transactions (
    id                    uuid          PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    transaction_reference varchar(50)   NOT NULL UNIQUE,
    user_id               uuid          REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id      uuid          REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    initiated_by_user_id  uuid          REFERENCES public.users(id) ON DELETE SET NULL,
    approved_by_user_id   uuid          REFERENCES public.users(id) ON DELETE SET NULL,
    pending_action_id     uuid          DEFAULT NULL,
    transaction_type      varchar(30)   NOT NULL,
    amount                numeric(15,2) NOT NULL,
    currency              varchar(3)    NOT NULL DEFAULT 'USD',
    from_account_id       uuid          DEFAULT NULL,
    to_account_id         uuid          DEFAULT NULL,
    from_user_id          uuid          REFERENCES public.users(id) ON DELETE SET NULL,
    to_user_id            uuid          REFERENCES public.users(id) ON DELETE SET NULL,
    from_email            varchar(255)  DEFAULT NULL,
    to_email              varchar(255)  DEFAULT NULL,
    description           text          DEFAULT NULL,
    metadata              jsonb         DEFAULT NULL,
    status                varchar(20)   NOT NULL DEFAULT 'pending',
    requires_approval     boolean       NOT NULL DEFAULT false,
    approval_level        varchar(20)   DEFAULT NULL,
    created_at            timestamptz   NOT NULL DEFAULT now(),
    updated_at            timestamptz   NOT NULL DEFAULT now(),
    processed_at          timestamptz   DEFAULT NULL,
    completed_at          timestamptz   DEFAULT NULL,
    failed_at             timestamptz   DEFAULT NULL,
    failure_reason        text          DEFAULT NULL,
    beneficiary_id        uuid          DEFAULT NULL,
    fee                   numeric(15,2) DEFAULT 0.00,
    total_amount          numeric(15,2) DEFAULT NULL,
    exchange_rate         numeric(10,4) DEFAULT 1.0000,
    estimated_delivery    timestamptz   DEFAULT NULL,
    notification_sent     boolean       DEFAULT false,
    crypto_coin           varchar(10)   DEFAULT NULL,
    crypto_amount         numeric(18,8) DEFAULT NULL,
    crypto_address        text          DEFAULT NULL,

    CONSTRAINT transactions_transaction_type_check CHECK (
        transaction_type = ANY (ARRAY[
            'send', 'receive', 'transfer', 'card_payment',
            'loan_disbursement', 'investment_deposit',
            'investment_withdrawal', 'fee', 'interest',
            'crypto_send', 'crypto_receive'
        ])
    ),
    CONSTRAINT transactions_status_check CHECK (
        status = ANY (ARRAY[
            'pending', 'processing', 'completed',
            'failed', 'rejected', 'cancelled'
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id          ON public.transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_joint_account_id ON public.transactions (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_type ON public.transactions (transaction_type);
CREATE INDEX IF NOT EXISTS idx_transactions_from_user_id     ON public.transactions (from_user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_to_user_id       ON public.transactions (to_user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_from_account     ON public.transactions (from_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_to_account       ON public.transactions (to_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status           ON public.transactions (status);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at       ON public.transactions (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_reference        ON public.transactions (transaction_reference);
CREATE INDEX IF NOT EXISTS idx_transactions_initiated_by     ON public.transactions (initiated_by_user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_pending_action   ON public.transactions (pending_action_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user             ON public.transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_joint            ON public.transactions (joint_account_id);

ALTER TABLE public.transactions
    ADD CONSTRAINT transactions_from_account_fkey
    FOREIGN KEY (from_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;

ALTER TABLE public.transactions
    ADD CONSTRAINT transactions_to_account_fkey
    FOREIGN KEY (to_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;

DROP TRIGGER IF EXISTS set_transaction_reference      ON public.transactions;
DROP TRIGGER IF EXISTS before_transaction_insert      ON public.transactions;
DROP TRIGGER IF EXISTS after_transaction_notification ON public.transactions;
DROP TRIGGER IF EXISTS after_transaction_update       ON public.transactions;
DROP TRIGGER IF EXISTS review_large_transactions      ON public.transactions;

CREATE TRIGGER set_transaction_reference
    BEFORE INSERT ON public.transactions
    FOR EACH ROW
    WHEN (NEW.transaction_reference IS NULL OR NEW.transaction_reference = '')
    EXECUTE FUNCTION public.generate_transaction_reference();

CREATE TRIGGER before_transaction_insert
    BEFORE INSERT ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_transaction_reference();

CREATE TRIGGER after_transaction_notification
    BEFORE UPDATE OF status ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.send_transaction_notification();

CREATE TRIGGER after_transaction_update
    AFTER UPDATE OF status ON public.transactions
    FOR EACH ROW
    WHEN (NEW.status = ANY (ARRAY['completed', 'processing']))
    EXECUTE FUNCTION public.update_beneficiary_usage();

CREATE TRIGGER review_large_transactions
    AFTER INSERT ON public.transactions
    FOR EACH ROW
    WHEN (NEW.amount > 10000)
    EXECUTE FUNCTION public.add_to_admin_review_queue();

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "transactions_all" ON public.transactions;
CREATE POLICY "transactions_all" ON public.transactions FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 9. PENDING ACTIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.pending_actions (
    id                   uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    joint_account_id     uuid        NOT NULL REFERENCES public.joint_accounts(id) ON DELETE CASCADE,
    initiated_by_user_id uuid        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    action_type          varchar(50) NOT NULL,
    action_data          jsonb       NOT NULL,
    status               varchar(20) NOT NULL DEFAULT 'pending',
    initiated_at         timestamptz NOT NULL DEFAULT now(),
    expires_at           timestamptz NOT NULL,
    completed_at         timestamptz DEFAULT NULL,
    approved_by_user_id  uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    rejected_by_user_id  uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    rejection_reason     text        DEFAULT NULL,

    CONSTRAINT pending_actions_action_type_check CHECK (
        action_type = ANY (ARRAY[
            'transaction',
            'card_application',
            'card_cancellation',
            'notification_delete',
            'notification_clear_all',
            'loan_application',
            'investment_goal',
            'account_deletion',
            'crypto_send'
        ])
    ),
    CONSTRAINT pending_actions_status_check CHECK (
        status = ANY (ARRAY[
            'pending', 'approved', 'rejected', 'expired'
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_pending_actions_joint_account ON public.pending_actions (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_pending_actions_status        ON public.pending_actions (status);
CREATE INDEX IF NOT EXISTS idx_pending_actions_expires       ON public.pending_actions (expires_at);
CREATE INDEX IF NOT EXISTS idx_pending_actions_initiated_by  ON public.pending_actions (initiated_by_user_id);
CREATE INDEX IF NOT EXISTS idx_pending_actions_joint         ON public.pending_actions (joint_account_id, status);

ALTER TABLE public.transactions
    ADD CONSTRAINT transactions_pending_action_id_fkey
    FOREIGN KEY (pending_action_id) REFERENCES public.pending_actions(id) ON DELETE SET NULL;

ALTER TABLE public.pending_actions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "pending_actions_all" ON public.pending_actions;
CREATE POLICY "pending_actions_all" ON public.pending_actions FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 10. BENEFICIARIES
-- ================================================================

CREATE TABLE IF NOT EXISTS public.beneficiaries (
    id                    uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id               uuid        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    beneficiary_reference varchar(50) NOT NULL UNIQUE,
    bank_name             varchar(255) NOT NULL,
    account_number        varchar(50)  NOT NULL,
    account_name          varchar(255) NOT NULL,
    routing_number        varchar(20)  DEFAULT NULL,
    swift_code            varchar(20)  DEFAULT NULL,
    iban                  varchar(50)  DEFAULT NULL,
    account_type          varchar(20)  DEFAULT 'checking',
    country               varchar(100) DEFAULT 'United States',
    is_us_bank            boolean      DEFAULT true,
    bank_address          text         DEFAULT NULL,
    email                 varchar(255) DEFAULT NULL,
    phone                 varchar(50)  DEFAULT NULL,
    nickname              varchar(100) DEFAULT NULL,
    is_active             boolean      DEFAULT true,
    transfer_count        integer      DEFAULT 0,
    last_used_at          timestamptz  DEFAULT NULL,
    created_at            timestamptz  NOT NULL DEFAULT now(),
    updated_at            timestamptz  NOT NULL DEFAULT now(),

    CONSTRAINT beneficiaries_user_account_unique UNIQUE (user_id, account_number, bank_name)
);

CREATE INDEX IF NOT EXISTS idx_beneficiaries_user_id   ON public.beneficiaries (user_id);
CREATE INDEX IF NOT EXISTS idx_beneficiaries_account   ON public.beneficiaries (account_number);
CREATE INDEX IF NOT EXISTS idx_beneficiaries_is_active ON public.beneficiaries (is_active);

-- Deferred FK: transactions → beneficiaries
ALTER TABLE public.transactions
    ADD CONSTRAINT  transactions_beneficiary_id_fkey
    FOREIGN KEY (beneficiary_id) REFERENCES public.beneficiaries(id) ON DELETE SET NULL;

ALTER TABLE public.beneficiaries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "beneficiaries_all" ON public.beneficiaries;
CREATE POLICY "beneficiaries_all" ON public.beneficiaries FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 11. CARD APPLICATIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.card_applications (
    id                    uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    application_reference varchar(50) NOT NULL UNIQUE,
    user_id               uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id      uuid        REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    initiated_by_user_id  uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    approved_by_user_id   uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    pending_action_id     uuid        REFERENCES public.pending_actions(id) ON DELETE SET NULL,
    card_type             varchar(50) NOT NULL,
    card_network          varchar(50) NOT NULL,
    card_tier             varchar(50) DEFAULT NULL,
    annual_income         numeric(15,2) DEFAULT NULL,
    employment_status     varchar(50) DEFAULT NULL,
    credit_score          integer     DEFAULT NULL,
    transaction_id        uuid        REFERENCES public.transactions(id) ON DELETE SET NULL,
    status                varchar(20) NOT NULL DEFAULT 'pending',
    admin_notes           text        DEFAULT NULL,
    rejection_reason      text        DEFAULT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    reviewed_at           timestamptz DEFAULT NULL,
    approved_at           timestamptz DEFAULT NULL,
    issued_at             timestamptz DEFAULT NULL,
    wallet_type           varchar(10) DEFAULT 'usd',
    crypto_coin           varchar(10) DEFAULT NULL,
    delivery_type         varchar(10) DEFAULT 'digital',
    shipping_name         text        DEFAULT NULL,
    shipping_address      text        DEFAULT NULL,
    card_number           varchar(16) DEFAULT NULL,
    card_expiry           varchar(5)  DEFAULT NULL,
    card_holder           varchar(255) DEFAULT NULL,

    CONSTRAINT card_applications_status_check CHECK (
        status = ANY (ARRAY[
            'pending'::varchar, 'processing'::varchar, 'approved'::varchar,
            'active'::varchar, 'shipped'::varchar, 'delivered'::varchar,
            'rejected'::varchar, 'cancelled'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_card_applications_user_id          ON public.card_applications (user_id);
CREATE INDEX IF NOT EXISTS idx_card_applications_joint_account_id ON public.card_applications (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_card_applications_status           ON public.card_applications (status);
CREATE INDEX IF NOT EXISTS idx_card_applications_created_at       ON public.card_applications (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_card_apps_user                     ON public.card_applications (user_id);

DROP TRIGGER IF EXISTS before_card_insert        ON public.card_applications;
DROP TRIGGER IF EXISTS review_card_applications  ON public.card_applications;

CREATE TRIGGER before_card_insert
    BEFORE INSERT ON public.card_applications
    FOR EACH ROW
    WHEN (NEW.application_reference IS NULL OR NEW.application_reference = '')
    EXECUTE FUNCTION public.generate_card_reference();

CREATE TRIGGER review_card_applications
    AFTER INSERT ON public.card_applications
    FOR EACH ROW
    WHEN (NEW.status = 'pending')
    EXECUTE FUNCTION public.add_to_admin_review_queue();

ALTER TABLE public.card_applications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "card_apps_all" ON public.card_applications;
CREATE POLICY "card_apps_all" ON public.card_applications FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 12. CARDS (issued cards, separate from card_applications)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.cards (
    id                    uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    card_number_encrypted text        NOT NULL,
    card_number_hash      text        NOT NULL UNIQUE,
    last_four             varchar(4)  NOT NULL,
    user_id               uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id      uuid        REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    application_id        uuid        REFERENCES public.card_applications(id) ON DELETE SET NULL,
    card_type             varchar(50) NOT NULL,
    network               varchar(50) NOT NULL,
    card_tier             varchar(50) DEFAULT NULL,
    expiry_month          integer     NOT NULL,
    expiry_year           integer     NOT NULL,
    cvv_encrypted         text        NOT NULL,
    pin_hash              text        DEFAULT NULL,
    daily_limit           numeric(15,2) DEFAULT NULL,
    monthly_limit         numeric(15,2) DEFAULT NULL,
    status                varchar(20) NOT NULL DEFAULT 'active',
    block_reason          text        DEFAULT NULL,
    issued_at             timestamptz NOT NULL DEFAULT now(),
    activated_at          timestamptz DEFAULT NULL,
    blocked_at            timestamptz DEFAULT NULL,
    expires_at            timestamptz NOT NULL,

    CONSTRAINT cards_status_check CHECK (
        status = ANY (ARRAY[
            'active'::varchar, 'blocked'::varchar,
            'expired'::varchar, 'cancelled'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_cards_user_id          ON public.cards (user_id);
CREATE INDEX IF NOT EXISTS idx_cards_joint_account_id ON public.cards (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_cards_last_four        ON public.cards (last_four);
CREATE INDEX IF NOT EXISTS idx_cards_status           ON public.cards (status);

ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "cards_all" ON public.cards;
CREATE POLICY "cards_all" ON public.cards FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 13. LOAN APPLICATIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.loan_applications (
    id                    uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    application_reference varchar(50) NOT NULL UNIQUE,
    user_id               uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id      uuid        REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    initiated_by_user_id  uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    approved_by_user_id   uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    pending_action_id     uuid        REFERENCES public.pending_actions(id) ON DELETE SET NULL,
    loan_type             varchar(50) NOT NULL,
    amount                numeric(15,2) NOT NULL,
    purpose               text        NOT NULL,
    term_months           integer     NOT NULL,
    annual_income         numeric(15,2) DEFAULT NULL,
    employment_status     varchar(50) DEFAULT NULL,
    credit_score          integer     DEFAULT NULL,
    existing_loans        numeric(15,2) DEFAULT 0,
    interest_rate         numeric(5,2)  DEFAULT NULL,
    monthly_payment       numeric(15,2) DEFAULT NULL,
    total_repayment       numeric(15,2) DEFAULT NULL,
    transaction_id        uuid        REFERENCES public.transactions(id) ON DELETE SET NULL,
    status                varchar(20) NOT NULL DEFAULT 'pending',
    admin_notes           text        DEFAULT NULL,
    rejection_reason      text        DEFAULT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    reviewed_at           timestamptz DEFAULT NULL,
    approved_at           timestamptz DEFAULT NULL,
    disbursed_at          timestamptz DEFAULT NULL,
    level                 integer     DEFAULT 1,
    total_repayable       numeric(15,2) DEFAULT NULL,
    disbursement_wallet   varchar(10) DEFAULT 'usd',
    crypto_coin           varchar(10) DEFAULT NULL,
    repaid                boolean     DEFAULT false,
    repaid_at             timestamptz DEFAULT NULL,
    amount_repaid         numeric(15,2) DEFAULT 0.00,

    CONSTRAINT loan_applications_status_check CHECK (
        status = ANY (ARRAY[
            'pending'::varchar, 'processing'::varchar, 'approved'::varchar,
            'disbursed'::varchar, 'rejected'::varchar,
            'cancelled'::varchar, 'repaid'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_loan_applications_user_id          ON public.loan_applications (user_id);
CREATE INDEX IF NOT EXISTS idx_loan_applications_joint_account_id ON public.loan_applications (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_loan_applications_status           ON public.loan_applications (status);
CREATE INDEX IF NOT EXISTS idx_loan_applications_created_at       ON public.loan_applications (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_loan_apps_user                     ON public.loan_applications (user_id);

DROP TRIGGER IF EXISTS before_loan_insert       ON public.loan_applications;
DROP TRIGGER IF EXISTS review_loan_applications ON public.loan_applications;

CREATE TRIGGER before_loan_insert
    BEFORE INSERT ON public.loan_applications
    FOR EACH ROW
    WHEN (NEW.application_reference IS NULL OR NEW.application_reference = '')
    EXECUTE FUNCTION public.generate_loan_reference();

CREATE TRIGGER review_loan_applications
    AFTER INSERT ON public.loan_applications
    FOR EACH ROW
    WHEN (NEW.status = 'pending')
    EXECUTE FUNCTION public.add_to_admin_review_queue();

ALTER TABLE public.loan_applications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "loan_apps_all" ON public.loan_applications;
CREATE POLICY "loan_apps_all" ON public.loan_applications FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 14. LOANS (active loan ledger, separate from applications)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.loans (
    id                  uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    loan_reference      varchar(50) NOT NULL UNIQUE,
    application_id      uuid        REFERENCES public.loan_applications(id) ON DELETE SET NULL,
    user_id             uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id    uuid        REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    loan_type           varchar(50) NOT NULL,
    principal_amount    numeric(15,2) NOT NULL,
    remaining_balance   numeric(15,2) NOT NULL,
    interest_rate       numeric(5,2)  NOT NULL,
    term_months         integer     NOT NULL,
    monthly_payment     numeric(15,2) NOT NULL,
    next_payment_date   date        DEFAULT NULL,
    next_payment_amount numeric(15,2) DEFAULT NULL,
    payments_made       integer     NOT NULL DEFAULT 0,
    payments_remaining  integer     NOT NULL,
    status              varchar(20) NOT NULL DEFAULT 'active',
    created_at          timestamptz NOT NULL DEFAULT now(),
    disbursed_at        timestamptz NOT NULL,
    first_payment_date  date        DEFAULT NULL,
    last_payment_date   date        DEFAULT NULL,
    closed_at           timestamptz DEFAULT NULL,

    CONSTRAINT loans_status_check CHECK (
        status = ANY (ARRAY[
            'active'::varchar, 'paid'::varchar,
            'defaulted'::varchar, 'restructured'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_loans_user_id          ON public.loans (user_id);
CREATE INDEX IF NOT EXISTS idx_loans_joint_account_id ON public.loans (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_loans_status           ON public.loans (status);

ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "loans_all" ON public.loans;
CREATE POLICY "loans_all" ON public.loans FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 15. INVESTMENTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.investments (
    id                   uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    investment_reference varchar(50) NOT NULL UNIQUE,
    user_id              uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    joint_account_id     uuid        REFERENCES public.joint_accounts(id) ON DELETE SET NULL,
    initiated_by_user_id uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    approved_by_user_id  uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    pending_action_id    uuid        REFERENCES public.pending_actions(id) ON DELETE SET NULL,
    goal_name            varchar(255) NOT NULL,
    investment_type      varchar(50) NOT NULL,
    target_amount        numeric(15,2) NOT NULL,
    current_value        numeric(15,2) NOT NULL,
    lock_period_months   integer     NOT NULL,
    roi_percentage       numeric(5,2) NOT NULL,
    projected_value      numeric(15,2) NOT NULL,
    transaction_id       uuid        REFERENCES public.transactions(id) ON DELETE SET NULL,
    status               varchar(20) NOT NULL DEFAULT 'pending',
    created_at           timestamptz NOT NULL DEFAULT now(),
    updated_at           timestamptz NOT NULL DEFAULT now(),
    activated_at         timestamptz DEFAULT NULL,
    matured_at           timestamptz DEFAULT NULL,
    withdrawn_at         timestamptz DEFAULT NULL,
    plan                 varchar(20) DEFAULT 'starter',
    multiplier           numeric(8,2) DEFAULT 20.00,
    locked_amount        numeric(15,2) DEFAULT 0.00,
    current_profit       numeric(15,2) DEFAULT 0.00,
    lock_months          integer     DEFAULT 3,
    top_ups              numeric(15,2) DEFAULT 0.00,

    CONSTRAINT investments_plan_check CHECK (
        plan = ANY (ARRAY['starter'::varchar, 'premium'::varchar, 'elite'::varchar])
    ),
    CONSTRAINT investments_status_check CHECK (
        status = ANY (ARRAY[
            'active'::varchar, 'matured'::varchar, 'withdrawn'::varchar,
            'cancelled'::varchar, 'pending'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_investments_user_id          ON public.investments (user_id);
CREATE INDEX IF NOT EXISTS idx_investments_joint_account_id ON public.investments (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_investments_status           ON public.investments (status);
CREATE INDEX IF NOT EXISTS idx_investments_created_at       ON public.investments (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_investments_user             ON public.investments (user_id);

DROP TRIGGER IF EXISTS before_investment_insert ON public.investments;
DROP TRIGGER IF EXISTS review_investments       ON public.investments;

CREATE TRIGGER before_investment_insert
    BEFORE INSERT ON public.investments
    FOR EACH ROW
    WHEN (NEW.investment_reference IS NULL OR NEW.investment_reference = '')
    EXECUTE FUNCTION public.generate_investment_reference();

CREATE TRIGGER review_investments
    AFTER INSERT ON public.investments
    FOR EACH ROW
    WHEN (NEW.status = 'pending')
    EXECUTE FUNCTION public.add_to_admin_review_queue();

ALTER TABLE public.investments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "investments_all" ON public.investments;
CREATE POLICY "investments_all" ON public.investments FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 16. NOTIFICATIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id               uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id          uuid        REFERENCES public.users(id) ON DELETE CASCADE,
    joint_account_id uuid        REFERENCES public.joint_accounts(id) ON DELETE CASCADE,
    title            text        NOT NULL,
    body             text        DEFAULT NULL,
    type             varchar(30) DEFAULT 'info',
    is_read          boolean     NOT NULL DEFAULT false,
    read_at          timestamptz DEFAULT NULL,
    created_at       timestamptz NOT NULL DEFAULT now(),
    metadata         jsonb       DEFAULT '{}',

    CONSTRAINT notifications_type_check CHECK (
        type = ANY (ARRAY[
            'info'::varchar, 'success'::varchar, 'warning'::varchar, 'error'::varchar,
            'transaction'::varchar, 'card'::varchar, 'loan'::varchar,
            'investment'::varchar, 'system'::varchar
        ])
    )
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id    ON public.notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_joint      ON public.notifications (joint_account_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read    ON public.notifications (is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications (created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "notifications_all" ON public.notifications;
CREATE POLICY "notifications_all" ON public.notifications FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 17. MONEY REQUESTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.money_requests (
    id              uuid        PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id         uuid        REFERENCES public.users(id) ON DELETE SET NULL,
    requester_email text        DEFAULT NULL,
    amount          numeric(15,2) DEFAULT NULL,
    description     text        DEFAULT NULL,
    status          text        DEFAULT 'pending',
    created_at      timestamptz DEFAULT now(),

    CONSTRAINT money_requests_status_check CHECK (
        status = ANY (ARRAY['pending'::text, 'paid'::text, 'declined'::text, 'cancelled'::text])
    )
);

ALTER TABLE public.money_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "money_requests_all" ON public.money_requests;
CREATE POLICY "money_requests_all" ON public.money_requests FOR ALL USING (true) WITH CHECK (true);


-- ================================================================
-- 18. VIEWS
-- ================================================================

CREATE OR REPLACE VIEW public.card_slots AS
SELECT
    COALESCE(user_id::text, joint_account_id::text) AS account_key,
    user_id,
    joint_account_id,
    SUM(CASE WHEN wallet_type = 'usd'    AND delivery_type = 'digital'  AND status NOT IN ('rejected','cancelled') THEN 1 ELSE 0 END) AS usd_digital,
    SUM(CASE WHEN wallet_type = 'usd'    AND delivery_type = 'physical' AND status NOT IN ('rejected','cancelled') THEN 1 ELSE 0 END) AS usd_physical,
    SUM(CASE WHEN wallet_type = 'crypto' AND delivery_type = 'digital'  AND status NOT IN ('rejected','cancelled') THEN 1 ELSE 0 END) AS crypto_digital,
    SUM(CASE WHEN wallet_type = 'crypto' AND delivery_type = 'physical' AND status NOT IN ('rejected','cancelled') THEN 1 ELSE 0 END) AS crypto_physical
FROM public.card_applications
GROUP BY user_id, joint_account_id;

CREATE OR REPLACE VIEW public.transaction_summary AS
SELECT
    t.id,
    t.transaction_reference,
    t.transaction_type,
    t.amount,
    t.currency,
    t.status,
    t.created_at,
    t.completed_at,
    u.email AS user_email,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    CASE
        WHEN t.joint_account_id IS NOT NULL THEN 'joint'
        ELSE 'individual'
    END AS account_type,
    t.description,
    t.metadata
FROM public.transactions t
LEFT JOIN public.users u
    ON u.id = t.user_id
    OR (t.joint_account_id IS NOT NULL AND u.joint_account_id = t.joint_account_id);

CREATE OR REPLACE VIEW public.user_transactions_view AS
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
    b.account_name          AS beneficiary_name,
    b.bank_name             AS beneficiary_bank,
    b.account_number        AS beneficiary_account,
    b.is_us_bank            AS beneficiary_is_us,
    CASE
        WHEN t.joint_account_id IS NOT NULL THEN 'joint'
        ELSE 'individual'
    END AS account_type,
    u.email                 AS user_email,
    u.first_name || ' ' || u.last_name AS user_full_name
FROM public.transactions t
LEFT JOIN public.beneficiaries b ON b.id = t.beneficiary_id
LEFT JOIN public.users u
    ON u.id = t.user_id
    OR (t.joint_account_id IS NOT NULL AND u.joint_account_id = t.joint_account_id);


-- ================================================================
-- 19. RELOAD SCHEMA CACHE
-- ================================================================

NOTIFY pgrst, 'reload schema';
