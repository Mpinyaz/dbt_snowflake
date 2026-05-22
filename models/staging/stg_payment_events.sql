select
    event_id,
    payment_id,
    event_type,
    merchant_id,
    amount,
    currency,
    card_scheme,
    status,
    created_at
from {{ source('raw', 'payment_events') }}
