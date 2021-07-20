(require 'cl-lib)
(require 'subr-x)
(require 'browse-url)
(require 'request)

;; browse-url-url-encode-chars
(setq company-backends (delete 'company-dragonruby company-backends))
(setq company-backends (delete 'company-dragonruby company-backends))
(setq company-backends (delete 'company-dragonruby company-backends))
(setq company-backends (delete 'company-dragonruby company-backends))

(defun company-dragonruby--buffer-text (buffer)
  (with-current-buffer buffer
                       (save-restriction (widen)
                                         (buffer-substring-no-properties (point-min) (point-max)))))

(defun company-dragonruby--mailbox-code-template ()
"
suggestions = $gtk.suggest_autocompletion index: :buffer-index, text: <<-COMPANY_DRAGONRUBY_BUFFERHEREDOC
:buffer-text
COMPANY_DRAGONRUBY_BUFFERHEREDOC

$gtk.write_file 'app/autocomplete.txt', suggestions.join(\"\\n\")
"
)

(defun company-dragonruby--mailbox-code (index code)
  (s-replace ":buffer-text"
             code
             (s-replace ":buffer-index"
                        (number-to-string index)
                        (company-dragonruby--mailbox-code-template))))

(defun company-dragonruby--read-autocomplete ()
  (if (file-exists-p "autocomplete.txt")
      (with-temp-buffer (insert-file-contents "autocomplete.txt")
                        (split-string (buffer-string) "\n" t))
      '()))

(defun amir-httpbin ()
  (interactive)
  (request "http://httpbin.org/put"
  :type "PUT"
  :data (json-encode '(("key" . "value") ("key2" . "value2")))
  :headers '(("Content-Type" . "application/json"))
  :parser 'json-read
  :success (cl-function
            (lambda (&key response &allow-other-keys)
              (message "I sent: %S" (assoc-default 'json data))))) )

(defun amir-try-request ()
  (interactive)
  (request "http://localhost:9001/dragon/autocomplete/"
           :type "POST"
           :data (json-encode '(("index" . "27") ("text" . "def tick args\n  args.state.\nend")))
           :parser 'buffer-string
           :error (cl-function
                   (lambda (&rest args &key error-thrown &allow-other-keys)
                     (message "Got error: %S" error-thrown)))
           :sync t
           :success
           (cl-function (lambda (&key data &allow-other-keys)
                          (when data
                            (format "%s" data))))))

(defun company-dragonruby--write-autocomplete ()
  (interactive)
  (let ((text (company-dragonruby--buffer-text (current-buffer)))
        (index (point)))
    (request "http://localhost:9001/dragon/autocomplete/"
             :type "POST"
             :data (json-encode `(("index" . ,index) ("text" . ,text)))
             :parser 'buffer-string
             :error (cl-function
                     (lambda (&rest args &key error-thrown &allow-other-keys)
                       (message "Got error: %S" error-thrown)))
             :sync t
             :success
             (cl-function (lambda (&key data &allow-other-keys)
                            (when data
                              (setq company-dragonruby--autocomplete-result (format "%s" data))))))))

(defun company-dragonruby--find-candidates (prefix)
  (let ((res '()))
    (company-dragonruby--write-autocomplete)
    (dolist (item (split-string company-dragonruby--autocomplete-result "\n" t))
      (when (string-prefix-p prefix item)
        (push (propertize item) res)))
    res))

(defun company-dragonruby (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-dragonruby))
    (prefix (and (eq major-mode 'ruby-mode)
                 (company-grab-symbol-cons "\\.\\|->" 2)))
    (candidates (company-dragonruby--find-candidates arg))))

(add-to-list 'company-backends 'company-dragonruby)
