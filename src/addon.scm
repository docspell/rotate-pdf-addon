#!/bin/sh
exec guile -e '(rotate-pdf-addon) main' -s $0 "$@"
!#
;; A simple addon for Docspell for rotating pdf files.
;;
;; It uses "qpdf" for rotating.

(define-module (rotate-pdf-addon)
  #:use-module (json)
  #:use-module (ice-9 rdelim)
  #:export (main))

;; Some helpers
(define* (errln formatstr . args)
  (apply format (current-error-port) formatstr args)
  (newline))

;; Macro for executing system commands and making this program exit in
;; case of failure.
(define-syntax sysexec
  (syntax-rules ()
    ((sysexec exp ...)
     (let ((rc (apply system* (list exp ...))))
       (unless (eqv? rc EXIT_SUCCESS)
         (format (current-error-port) "> '~a …' failed with: ~#*~:*~d~%" exp ... rc)
         (exit 1))
       #t))))

(fluid-set! %default-port-encoding "UTF-8")

;; External program dependencies
(define *qpdf* "qpdf")
(define *pdftotext* "pdftotext")

;; Getting some environment variables
(define *output-dir* (getenv "OUTPUT_DIR"))
(define *item-data-json* (getenv "ITEM_DATA_JSON"))
(define *pdf-files-dir* (getenv "ITEM_PDF_DIR"))

;; fail early if not in the right context
(when (not *item-data-json*)
  (errln "No item data json file found.")
  (exit 1))

;; The user input schema
(define-json-type <userinput>
  (degree))

;; The itemdata record, only the fields needed here.
(define-json-type <attachment>
  (id)
  (name)
  (position)
  (pages))
(define-json-type <itemdata>
  (id)
  (attachments "attachments" #(<attachment>)))

;; The output record, what is returned to docspell
(define-json-type <itemfiles>
  (itemId)
  (textFiles)
  (pdfFiles))
(define-json-type <output>
  (files "files" #(<itemfiles>)))

(define (load-itemdata)
  "Load the JSON file containing item data into the itemdata record."
  (scm->itemdata (call-with-input-file *item-data-json* json->scm)))

(define (load-user-input file)
  (scm->userinput (call-with-input-file file json->scm)))

(define (rotate-pdf file degree out txt)
  (errln "Running qpdf to rotate ~s" degree)
  (sysexec *qpdf* (format #f "--rotate=~a" degree) file out)
  (errln "Running pdftotext to extract the text from rotatet file")
  (sysexec *pdftotext* out txt))

(define (process-file itemid degree file)
  "Processing a single attachment."
  (let* ((id (attachment-id file))
         (name (attachment-name file))
         (file (format #f "~a/~a" *pdf-files-dir* id))
         (out (format #f "~a/~a.pdf" *output-dir* id))
         (txt (format #f "~a/~a.txt" *output-dir* id)))
    (errln "Processing attachment ~s" name)
    (rotate-pdf file degree out txt)
    (make-itemfiles itemid
                    `((,id . ,(format #f "~a.txt" id)))
                    `((,id . ,(format #f "~a.pdf" id))))))

(define (process-all indata)
  (let* ((item-meta (load-itemdata))
         (item-id (itemdata-id item-meta))
         (attachs (itemdata-attachments item-meta))
         (degree (userinput-degree indata)))
    (map (lambda (file)
           (process-file item-id degree file))
         attachs)))

(define (main args)
  (let* ((infile (load-user-input (cadr args)))
         (out (make-output (process-all infile))))
    (format #t "~a" (output->json out))))

;; Local Variables:
;; mode: scheme
;; End:
