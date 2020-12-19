(require 'cl-lib)
(require 'subr-x)

(setq company-backends (delete 'company-dragonruby company-backends))

(defun company-dragonruby--buffer-text (buffer)
  (with-current-buffer buffer
                       (save-restriction (widen)
                                         (buffer-substring-no-properties (point-min) (point-max)))))

(defvar company-dragonruby--mailbox-code
"
suggestions = $gtk.suggest_autocompletion index: :buffer-index, text: <<-S
:buffer-text
S

$gtk.write_file 'app/autocomplete.txt', suggestions.join(\"\\n\")
"
)

(defun company-dragonruby--mailbox-code-for (index code)
  (s-replace ":buffer-text"
             code
             (s-replace ":buffer-index"
                        (number-to-string index)
                        company-dragonruby--mailbox-code)))

(defun company-dragonruby--read-autocomplete ()
  (if (file-exists-p "autocomplete.txt")
      (with-temp-buffer (insert-file-contents "autocomplete.txt")
                        (split-string (buffer-string) "\n" t))
      '()))

(defun company-dragonruby--write-autocomplete ()
  (let ((code (company-dragonruby--buffer-text (current-buffer)))
        (index (point)))
    (let ((final-code (company-dragonruby--mailbox-code-for index code)))
      (write-region final-code nil "./mailbox.txt")
      (shell-command-to-string "ruby ./autocomplete-mri.rb"))))

(defun company-dragonruby--find-candidates (prefix)
  (let (res)
    (company-dragonruby--write-autocomplete)
    (dolist (item (company-dragonruby--read-autocomplete))
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
