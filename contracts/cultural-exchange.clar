;; Inter-Species Cultural Exchange Contract

(define-data-var exchange-counter uint u0)

(define-map cultural-exchanges uint {
    organizer: principal,
    species-a: (string-ascii 100),
    species-b: (string-ascii 100),
    theme: (string-utf8 500),
    start-time: uint,
    duration: uint,
    status: (string-ascii 20),
    insights: (list 10 (string-utf8 1000))
})

(define-public (create-exchange (species-a (string-ascii 100)) (species-b (string-ascii 100)) (theme (string-utf8 500)) (start-time uint) (duration uint))
    (let
        ((new-id (+ (var-get exchange-counter) u1)))
        (map-set cultural-exchanges new-id {
            organizer: tx-sender,
            species-a: species-a,
            species-b: species-b,
            theme: theme,
            start-time: start-time,
            duration: duration,
            status: "scheduled",
            insights: (list)
        })
        (var-set exchange-counter new-id)
        (ok new-id)
    )
)

(define-public (update-exchange-status (exchange-id uint) (new-status (string-ascii 20)))
    (let
        ((exchange (unwrap! (map-get? cultural-exchanges exchange-id) (err u404))))
        (asserts! (is-eq tx-sender (get organizer exchange)) (err u403))
        (ok (map-set cultural-exchanges exchange-id
            (merge exchange { status: new-status })))
    )
)

(define-public (add-cultural-insight (exchange-id uint) (insight (string-utf8 1000)))
    (let
        ((exchange (unwrap! (map-get? cultural-exchanges exchange-id) (err u404))))
        (asserts! (< (len (get insights exchange)) u10) (err u400))
        (ok (map-set cultural-exchanges exchange-id
            (merge exchange {
                insights: (unwrap! (as-max-len? (append (get insights exchange) insight) u10) (err u401))
            })))
    )
)

(define-read-only (get-exchange (exchange-id uint))
    (map-get? cultural-exchanges exchange-id)
)

(define-read-only (get-exchange-count)
    (var-get exchange-counter)
)

