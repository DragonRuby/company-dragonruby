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

(defun company-dragonruby--get-autocomplete ()
  (interactive)
  (let* ((text (company-dragonruby--buffer-text (current-buffer)))
	 (index (point))
	 (char-at-index-for-text (string (aref text (- index 2)))))
    (if (string= char-at-index-for-text ".")
	(request "http://localhost:9001/dragon/autocomplete/"
	  :type "POST"
	  :data (json-encode `(("index" . ,index) ("text" . ,text)))
	  :parser 'buffer-string
	  :error (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
				(message "Got error: %S" error-thrown)))
	  :sync t
	  :success
	  (cl-function (lambda (&key data &allow-other-keys)
			 (when data
			   (setq company-dragonruby--autocomplete-result (format "%s" data))))))
      (setq company-dragonruby--autocomplete-result ""))))

(defun company-dragonruby--find-candidates (prefix)
  (let ((res '()))
    (company-dragonruby--get-autocomplete)
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
