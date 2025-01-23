;; Collective Problem-Solving Contract

(define-data-var problem-counter uint u0)

(define-map collective-problems uint {
    creator: principal,
    description: (string-utf8 1000),
    category: (string-ascii 50),
    status: (string-ascii 20),
    created-at: uint,
    solved-at: uint,
    solution: (optional (string-utf8 1000))
})

(define-map problem-contributors (tuple (problem-id uint) (contributor principal)) bool)

(define-public (create-problem (description (string-utf8 1000)) (category (string-ascii 50)))
    (let
        ((new-id (+ (var-get problem-counter) u1)))
        (map-set collective-problems new-id {
            creator: tx-sender,
            description: description,
            category: category,
            status: "open",
            created-at: block-height,
            solved-at: u0,
            solution: none
        })
        (var-set problem-counter new-id)
        (ok new-id)
    )
)

(define-public (contribute-to-problem (problem-id uint))
    (ok (map-set problem-contributors {problem-id: problem-id, contributor: tx-sender} true))
)

(define-public (submit-solution (problem-id uint) (solution (string-utf8 1000)))
    (let
        ((problem (unwrap! (map-get? collective-problems problem-id) (err u404))))
        (asserts! (is-eq (get status problem) "open") (err u403))
        (ok (map-set collective-problems problem-id
            (merge problem {
                status: "solved",
                solved-at: block-height,
                solution: (some solution)
            })))
    )
)

(define-read-only (get-problem (problem-id uint))
    (map-get? collective-problems problem-id)
)

(define-read-only (is-problem-contributor (problem-id uint) (contributor principal))
    (default-to false (map-get? problem-contributors {problem-id: problem-id, contributor: contributor}))
)

(define-read-only (get-problem-count)
    (var-get problem-counter)
)

