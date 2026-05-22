with authorisations as (
    select payment_id, merchant_id, amount, currency, card_scheme, created_at as authorised_at
    from {{ ref('stg_payment_events') }}
    where event_type = 'authorised' and status = 'success'
),
refunds as (
    select payment_id, sum(amount) as refunded_amount
    from {{ ref('stg_payment_events') }}
    where event_type = 'refunded'
    group by payment_id
),
chargebacks as (
    select payment_id, sum(amount) as chargeback_amount
    from {{ ref('stg_payment_events') }}
    where event_type = 'charged_back'
    group by payment_id
)
select
    a.payment_id,
    a.merchant_id,
    a.amount                                        as gross_amount,
    coalesce(r.refunded_amount, 0)                  as refunded_amount,
    coalesce(c.chargeback_amount, 0)                as chargeback_amount,
    a.amount
        - coalesce(r.refunded_amount, 0)
        - coalesce(c.chargeback_amount, 0)          as net_amount,
    a.currency,
    a.card_scheme,
    a.authorised_at
from authorisations a
left join refunds r on a.payment_id = r.payment_id
left join chargebacks c on a.payment_id = c.payment_id
