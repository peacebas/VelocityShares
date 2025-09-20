;; VelocityShares (VELS) - Dividend Distributing Token
;; A smart contract for distributing dividends to token holders

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-zero-amount (err u103))
(define-constant err-already-claimed (err u104))
(define-constant err-no-dividends (err u105))

;; Token trait implementation
;; Note: Replace with actual SIP-010 trait reference when deploying
;; (impl-trait .sip-010-trait-ft-standard.sip-010-trait)

;; Data variables
(define-data-var token-name (string-ascii 32) "VelocityShares")
(define-data-var token-symbol (string-ascii 10) "VELS")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var token-decimals uint u6)
(define-data-var total-supply uint u0)
(define-data-var yield-pool uint u0)
(define-data-var yield-per-token uint u0)
(define-data-var distribution-epoch uint u0)

;; Data maps
(define-map token-balances principal uint)
(define-map token-supplies uint uint)
(define-map allowances {owner: principal, spender: principal} uint)
(define-map yield-claims {user: principal, epoch: uint} bool)
(define-map participant-last-claim principal uint)

;; SIP-010 Functions

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-balance (who principal))
  (ok (default-to u0 (map-get? token-balances who))))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq from tx-sender) (is-eq from contract-caller)) err-not-token-owner)
    (asserts! (> amount u0) err-zero-amount)
    (asserts! (>= (get-balance-uint from) amount) err-insufficient-balance)
    (try! (ft-transfer? velocityshares-token amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)))

;; Internal helper functions
(define-private (get-balance-uint (who principal))
  (default-to u0 (map-get? token-balances who)))

(define-private (set-balance (who principal) (amount uint))
  (map-set token-balances who amount))

;; Define the fungible token
(define-fungible-token velocityshares-token)

;; Mint function (only owner)
(define-public (mint (amount uint) (to principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-zero-amount)
    (try! (ft-mint? velocityshares-token amount to))
    (set-balance to (+ (get-balance-uint to) amount))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)))

;; Burn function
(define-public (burn (amount uint) (from principal))
  (begin
    (asserts! (or (is-eq from tx-sender) (is-eq from contract-caller)) err-not-token-owner)
    (asserts! (> amount u0) err-zero-amount)
    (asserts! (>= (get-balance-uint from) amount) err-insufficient-balance)
    (try! (ft-burn? velocityshares-token amount from))
    (set-balance from (- (get-balance-uint from) amount))
    (var-set total-supply (- (var-get total-supply) amount))
    (ok true)))

;; Yield Distribution Functions

;; Deposit STX to yield pool (only owner)
(define-public (deposit-yield (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-zero-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set yield-pool (+ (var-get yield-pool) amount))
    (ok true)))

;; Distribute yield to all token holders
(define-public (distribute-yield)
  (let
    ((total-tokens (var-get total-supply))
     (pool-amount (var-get yield-pool)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> pool-amount u0) err-no-dividends)
    (asserts! (> total-tokens u0) err-no-dividends)
    (var-set yield-per-token (/ (* pool-amount u1000000) total-tokens))
    (var-set distribution-epoch (+ (var-get distribution-epoch) u1))
    (var-set yield-pool u0)
    (ok true)))

;; Calculate claimable yield for a user
(define-read-only (get-claimable-yield (user principal))
  (let
     ((user-balance (get-balance-uint user))
      (yield-rate (var-get yield-per-token))
      (current-epoch (var-get distribution-epoch))
      (last-claim (default-to u0 (map-get? participant-last-claim user))))
    (if (and (> current-epoch last-claim) (> yield-rate u0))
      (/ (* user-balance yield-rate) u1000000)
      u0)))

;; Claim yield
(define-public (claim-yield)
  (let
    ((user tx-sender)
     (claimable (get-claimable-yield tx-sender))
     (current-epoch (var-get distribution-epoch)))
    (asserts! (> claimable u0) err-no-dividends)
    (asserts! (is-none (map-get? yield-claims {user: user, epoch: current-epoch})) err-already-claimed)
    (try! (as-contract (stx-transfer? claimable tx-sender user)))
    (map-set yield-claims {user: user, epoch: current-epoch} true)
    (map-set participant-last-claim user current-epoch)
    (ok claimable)))

;; Read-only functions for yield information
(define-read-only (get-yield-pool)
  (var-get yield-pool))

(define-read-only (get-yield-per-token)
  (var-get yield-per-token))

(define-read-only (get-distribution-epoch)
  (var-get distribution-epoch))

(define-read-only (get-participant-last-claim (user principal))
  (default-to u0 (map-get? participant-last-claim user)))

;; Check if user has claimed yield for a specific epoch
(define-read-only (has-claimed-epoch (user principal) (epoch uint))
  (default-to false (map-get? yield-claims {user: user, epoch: epoch})))

;; Administrative functions
(define-public (set-token-uri (value (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set token-uri value)
    (ok true)))

;; Emergency withdrawal (only owner)
(define-public (emergency-withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (ok true)))