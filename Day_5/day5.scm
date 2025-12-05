(use-modules (ice-9 textual-ports))
(use-modules (ice-9 rdelim))

(define (parse-range s)
  (map string->number (string-split s #\-))) ; what a stupid syntax for char literals

(define (in-range rng v)
  (let ((lb (car rng))
        (ub (car (cdr rng))))
    (and (>= v lb) (<= v ub))))

(define (in-ranges rngs v)
  (cond
    ((null? rngs) #f)
    ((in-range (car rngs) v) #t)
    (else (in-ranges (cdr rngs) v))))

(define (read-to-blank-or-end dest)
  (let ((line (read-line)))
    (cond 
      ((eof-object? line) dest)
      ((string=? line "") dest)
      (else (read-to-blank-or-end (cons line dest))))))

(define (fold rngs vs acc)
  (if (null? vs) acc
    (fold rngs (cdr vs) (if (in-ranges rngs (car vs)) (+ acc 1) acc))))

(define (part1)
  (let ((unspoiled-ranges (map parse-range (read-to-blank-or-end '())))
        (available-ids (map string->number (read-to-blank-or-end '()))))
    (fold unspoiled-ranges available-ids 0)))

(let ((mode (read-line)))
  (display (string-append mode ": "))
  (display 
    (cond
      ((string=? mode "part1") (part1))
      ; (string=? mode "part2") (part2))
      (else (string-append (string-append "Bad mode: >" mode) "<"))))
  (display "\n"))
