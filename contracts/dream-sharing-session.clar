;; Dream Sharing Session Contract

(define-data-var session-counter uint u0)

(define-map dream-sessions uint {
    organizer: principal,
    participants: (list 100 principal),
    start-time: uint,
    duration: uint,
    theme: (string-utf8 500),
    status: (string-ascii 20)
})

(define-public (create-session (theme (string-utf8 500)) (start-time uint) (duration uint))
    (let
        ((new-id (+ (var-get session-counter) u1)))
        (map-set dream-sessions new-id {
            organizer: tx-sender,
            participants: (list tx-sender),
            start-time: start-time,
            duration: duration,
            theme: theme,
            status: "scheduled"
        })
        (var-set session-counter new-id)
        (ok new-id)
    )
)

(define-public (join-session (session-id uint))
    (let
        ((session (unwrap! (map-get? dream-sessions session-id) (err u404))))
        (asserts! (< (len (get participants session)) u100) (err u400))
        (ok (map-set dream-sessions session-id
            (merge session {
                participants: (unwrap! (as-max-len? (append (get participants session) tx-sender) u100) (err u401))
            })))
    )
)

(define-public (update-session-status (session-id uint) (new-status (string-ascii 20)))
    (let
        ((session (unwrap! (map-get? dream-sessions session-id) (err u404))))
        (asserts! (is-eq tx-sender (get organizer session)) (err u403))
        (ok (map-set dream-sessions session-id
            (merge session { status: new-status })))
    )
)

(define-read-only (get-session (session-id uint))
    (map-get? dream-sessions session-id)
)

(define-read-only (get-session-count)
    (var-get session-counter)
)

