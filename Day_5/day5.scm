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

(define (cmp-rngs l r)
  (< (car l) (car r)))

(define (replace-top-ub rngs ub)
  (let* ((lb (car (car rngs)))
         (new-car (cons lb (cons ub '()))))
    (cons new-car (cdr rngs))))

(define (rng-overlaps? l r)
  (let ((lub (car (cdr l)))
        (rlb (car r)))
    (>= lub rlb)))

(define (rng-extends? l r)
  (let ((lub (car (cdr l)))
        (rub (car (cdr r))))
    (< lub rub)))

(define (sum-ranges-inclusive rngs acc)
  (if (null? rngs)
    acc
    (let* ((head (car rngs))
           (ub (car (cdr head)))
           (lb (car head)))
      (sum-ranges-inclusive (cdr rngs) (+ acc (+ (- ub lb) 1))))))

(define (combine-overlapping sorted-overlapping-ranges combined-ranges)
  (let ((so sorted-overlapping-ranges)
        (cr combined-ranges))
    (if (null? so)
      cr
      (cond
        ((and (rng-overlaps? (car cr) (car so)) (rng-extends? (car cr) (car so))) (combine-overlapping (cdr so) (replace-top-ub cr (car (cdr (car so))))))
        ((rng-overlaps? (car cr) (car so)) (combine-overlapping (cdr so) cr))
        (else (combine-overlapping (cdr so) (cons (car so) cr)))))))

(define (part2)
  (let* ((unspoiled-ranges (map parse-range (read-to-blank-or-end '())))
         (sorted-ranges (sort unspoiled-ranges cmp-rngs))
         (combined-ranges (combine-overlapping (cdr sorted-ranges) (cons (car sorted-ranges) '()))))
    (sum-ranges-inclusive combined-ranges 0)))

(let ((mode (read-line)))
  (display (string-append mode ": "))
  (display 
    (cond
      ((string=? mode "part1") (part1))
      ((string=? mode "part2") (part2))
      (else (string-append (string-append "Bad mode: >" mode) "<"))))
  (display "\n"))
